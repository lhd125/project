`timescale 1ns / 1ps

module ch1_tb1;

    // 파라미터 정의 (테스트를 위해 가상의 4x4 입력을 가정, 풀링 후 2x2 = 총 4개 입력)
    parameter CONV_BIT     = 12;
    parameter WEIGHT_BIT   = 8;
    parameter ACCUM_BIT    = 32;
    parameter ADDR_BIT     = 10;
    parameter INPUT_WIDTH  = 4;   // 가상의 4x4 피처맵 가정
    parameter TOTAL_INPUT  = 4;   // 2x2 풀링 후 FC로 들어갈 총 데이터 개수 (2x2=4)

    // 테스트벤치용 신호 선언
    reg clk;
    reg rst_n;
    reg valid_in;
    reg signed [CONV_BIT-1:0] conv_out;
    
    // 모듈 간 연결용 내부 Wire
    wire valid_out_relu;
    wire signed [CONV_BIT-1:0] max_value;
    wire zero_skip_flag;
    
    wire [ADDR_BIT-1:0] weight_addr;
    wire weight_en;
    wire signed [ACCUM_BIT-1:0] data_out;
    wire valid_out_fc;

    // 가상의 가중치 메모리 (가중치는 편의상 모두 '2'로 고정해서 곱해지나 확인)
    wire signed [WEIGHT_BIT-1:0] test_weight = 8'd2;

    // --------------------------------------------------------
    // 1. [DUT 1] 현도님의 MaxPool + ReLU 1ch 모듈 인스턴스[cite: 3]
    // --------------------------------------------------------
    maxpool_relu_1ch #(
        .CONV_BIT(CONV_BIT),
        .HALF_WIDTH(INPUT_WIDTH/2), // 4/2 = 2
        .HALF_WIDTH_BIT(3)
    ) u_maxpool_relu (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .conv_out(conv_out),
        .valid_out_relu(valid_out_relu),
        .max_value(max_value),
        .zero_skip(zero_skip_flag)
    );

    // --------------------------------------------------------
    // 2. [DUT 2] 보정된 1ch Fully Connected 모듈 인스턴스
    // --------------------------------------------------------
    fc_1ch #(
        .DATA_BIT(CONV_BIT),
        .WEIGHT_BIT(WEIGHT_BIT),
        .ACCUM_BIT(ACCUM_BIT),
        .ADDR_BIT(ADDR_BIT),
        .TOTAL_INPUT(TOTAL_INPUT) // 4개 데이터 카운트 후 출력
    ) u_fc (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_out_relu),      // 풀링의 유효 신호가 FC의 valid_in으로!
        .skip_enable(zero_skip_flag),   // 제로스킵 깃발이 FC의 skip으로 다이렉트 연결!
        .data_in(max_value),            // 풀링된 값이 데이터 입력으로!
        .weight_addr(weight_addr),
        .weight_en(weight_en),
        .weight_in(test_weight),        // 가상의 고정 가중치 공급
        .data_out(data_out),
        .valid_out_fc(valid_out_fc)
    );

    // --------------------------------------------------------
    // 3. 클럭 생성 (10ns 주기 = 100MHz)
    // --------------------------------------------------------
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // 4. 테스트 시나리오 주입
    // --------------------------------------------------------
    initial begin
        // 초기화
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        conv_out = 0;
        
        #20;
        rst_n = 1; // 리셋 해제
        #10;

        // --- 시나리오: 4x4 크기의 피처맵 스트리밍 입력 주입 ---
        // 1번째 줄 입력 (2x2 윈도우의 첫 줄 세트)
        send_pixel(12'd5);  send_pixel(12'd3);  send_pixel(12'd10); send_pixel(12'd1);  
        // 2번째 줄 입력 (1차 풀링 완료 타이밍 ➡️ 대푯값 5와 10 추출되어 FC 진입 예상)
        send_pixel(12'd2);  send_pixel(12'd4);  send_pixel(12'd7);  send_pixel(12'd8);  
        
        // 3번째 줄 입력 (2x2 윈도우의 두 번째 세트 - 음수 및 0 유도)
        send_pixel(-12'd5); send_pixel(-12'd2); send_pixel(12'd0);  send_pixel(12'd0);  
        // 4번째 줄 입력 (2차 풀링 완료 타이밍 ➡️ 대푯값 0(음수 커트)과 0 추출되어 제로스킵 발동 예상)
        send_pixel(-12'd1); send_pixel(-12'd9); send_pixel(12'd0);  send_pixel(12'd0);  

        // 입력 종료
        valid_in = 0;
        conv_out = 0;

        // FC의 최종 연산 출력이 나올 때까지 충분히 대기
        @(posedge valid_out_fc);
        #20;
        
        $display("=================================================");
        $display("FC 최종 연산 출력 완료! 값: %d", data_out);
        $display("=================================================");
        $finish;
    end

    // 픽셀 주입용 헬퍼 태스크(Task)
    task send_pixel(input [CONV_BIT-1:0] val);
        begin
            @(posedge clk);
            valid_in = 1;
            conv_out = val;
        end
    endtask

endmodule