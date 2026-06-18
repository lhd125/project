module spi_4wire_top(
    input wire iclk,
    input [9:0] SW,
    input [1:0] KEY,
    input wire [1:0] interrupt,
    output wire  csn, sclk,
    input wire spi_MISO,
    output wire spi_MOSI,
    output [9:0] LEDR,
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
    output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS);

    `include "spi_4wire.h"
			
    wire spi_start;
    wire frame_start;
    wire frame_end;
    wire [SO_DataL:0] odata;
    wire spi_ready;
    wire spi_finish;
    wire [SO_DataL:0] i_byte;
    wire [SO_DataL:0] o_byte;
    wire signed [SI_DataL:0] acc_x;
    wire signed [SI_DataL:0] acc_y;
    wire signed [SI_DataL:0] acc_z;
    wire data_valid;
    wire [7:0]      w_int_source;
	reg [SI_DataL:0] disp_x, disp_y, disp_z;
    wire [9:0] col;
    wire [8:0] row;
    wire VGA_hs, VGA_vs;
    wire int1_signal = interrupt[0]; // interrupt pin of single tap function
    wire int2_signal = interrupt[1]; // interrupt pin of double tap and free-fall function
    wire [3:0] oDATA_R, oDATA_G, oDATA_B;
	 reg [2:0] sel_color;
always @(posedge iclk or negedge SW[9]) begin
  if(!SW[9]) begin
    disp_x <= 0;
    disp_y <= 0;
    disp_z <= 0;
  end else if(data_valid) begin
    disp_x <= acc_x;
    disp_y <= acc_y;
    disp_z <= acc_z;
  end
end
    reg prev_int1;
    reg prev_int2;
    reg [25:0] tap_debounce_cnt;
always@(posedge iclk)
begin
	prev_int1 <= int1_signal;
	prev_int2 <= int2_signal;
end

wire int1_pulse = int1_signal && ~prev_int1;
wire int2_pulse = int2_signal && ~prev_int2;
    reg [2:0] cnt;


always@(posedge iclk or negedge SW[9]) begin
	if(~SW[9]) begin
		cnt <= 0;
		tap_debounce_cnt <= 0;
		end
	else begin
		if(tap_debounce_cnt > 0) tap_debounce_cnt <= tap_debounce_cnt - 1;
		else if(int2_pulse) tap_debounce_cnt <= 26'd25_000_000;
		else if(int1_pulse) begin
			cnt <= cnt + 1;
			if(cnt == 3'h7) cnt <= 0;
		end
	end
end
always@(posedge iclk or negedge SW[9]) begin
	if(~SW[9]) begin
	sel_color <= 0;
	end
	else sel_color <= cnt;
	end	



    spi_4wire_FSM u_spi_4wire_FSM (
        .iclk(iclk),
        .irstn(SW[9]),
        .spi_ready(spi_ready),
        .spi_finish(spi_finish),
        .idata(o_byte),
        .ig_int2(interrupt[0]),
        .spi_start(spi_start),
        .frame_start(frame_start),
        .frame_end(frame_end),
        .odata(i_byte),
        .data_x(acc_x),
        .data_y(acc_y),
        .data_z(acc_z),
        .data_valid(data_valid),
		  .int_source(w_int_source)
    );

    spi_master_core u_spi_master_core (
        .iclk(iclk),
        .irst_n(SW[9]),
        .spi_start(spi_start),
        .frame_start(frame_start),
        .frame_end(frame_end),
        .i_byte(i_byte),
        .spi_ready(spi_ready),
        .spi_finish(spi_finish),
        .o_data(o_byte),
        .spi_MOSI(spi_MOSI),
        .spi_MISO(spi_MISO),
        .sclk(sclk),
        .csn(csn)
    );
	 
    PLL_1 u_vga_pll(
        .inclk0(iclk),
        .c0(pclk)
    );


	 Sync_Generator u_sync_generator (
        .pclk(pclk),
        .iRSTn(SW[9]),
        .h_sync_d(VGA_hs),
        .v_sync_d(VGA_vs),
        .col(col),
        .row(row)
     );

     VGA_Controller u_vga_controller(
        .pclk(pclk),
        .iRSTn(SW[9]),
        .col(col),
        .row(row),
        .col_index(sel_color),
        .ikey_draw(KEY[0]),
        .ikey_erase(KEY[1]),
        .iff(interrupt[1]),
        .iDATA_X(disp_x),
        .iDATA_Y(disp_y),
        .iDATA_Z(disp_z),
        .oData_R(oDATA_R),
        .oData_G(oDATA_G),
        .oData_B(oDATA_B)
     );

    D_REG #(.WIDTH(1)) 
    Reg_HS (.iCLK(pclk), .iRSTn(SW[9]), .iEN(1'b1), .iDATA(VGA_hs), .oDATA(VGA_HS));
    
    D_REG #(.WIDTH(1)) 
    Reg_VS (.iCLK(pclk), .iRSTn(SW[9]), .iEN(1'b1), .iDATA(VGA_vs), .oDATA(VGA_VS));
	
    D_REG #(.WIDTH(4))
	    D1(.iCLK(pclk), .iRSTn(SW[9]), .iEN(1'b1), .iDATA(oDATA_R), .oDATA(VGA_R));
	
    D_REG #(.WIDTH(4))
	    D2(.iCLK(pclk), .iRSTn(SW[9]), .iEN(1'b1), .iDATA(oDATA_G), .oDATA(VGA_G));
	
    D_REG #(.WIDTH(4))
	    D3(.iCLK(pclk), .iRSTn(SW[9]), .iEN(1'b1), .iDATA(oDATA_B), .oDATA(VGA_B));

    /*spi_led u_spi_led (
        .iclk(iclk),
        .irstn(SW[9]),
        .sw_sel(SW[1:0]),
        .data_x(acc_x),
        .data_y(acc_y),
        .data_z(acc_z),
        .LEDR(LEDR)
    );*/
	 //assign LEDR[0] = spi_start;
//assign LEDR[1] = spi_finish;
/*assign LEDR[2] = csn;        // 1이면 idle, 0이면 active
assign LEDR[3] = spi_MOSI;
assign LEDR[4] = sclk;       // 너가 이미 확인한 것
assign LEDR[5] = spi_MISO;       // 가능하면
assign LEDR[6] = data_valid;
assign LEDR[7] = spi_ready; */

reg [9:0] led_status;

  // [1. 절대값 변환 로직 추가]
    // data_x의 15번째 비트(부호)가 1이면(음수면) 뒤집고 +1, 아니면 그대로
    wire [15:0] real_x;
    wire [15:0] real_y;
    wire [15:0] real_z;

    assign real_x = {{3{acc_x[12]}}, disp_x[12:0]};
    assign real_y = {{3{acc_y[12]}}, disp_y[12:0]};
    assign real_z = {{3{acc_z[12]}}, disp_z[12:0]};

    // =============================================================
    // [2] 절대값 변환 (화면 표시용)
    // =============================================================
    // 이제 확장된 real_x의 15번 비트를 보면 정확한 부호를 알 수 있습니다.
    
    wire [15:0] abs_x = real_x[15] ? (~real_x + 1'b1) : real_x;
    wire [15:0] abs_y = real_y[15] ? (~real_y + 1'b1) : real_y;
    wire [15:0] abs_z = real_z[15] ? (~real_z + 1'b1) : real_z;

    // =============================================================
    // [3] LED 디버깅 (상태 확인)
    // =============================================================
    reg dbg_finish;

    always @(posedge iclk or negedge SW[9]) begin
        if(!SW[9]) dbg_finish <= 1'b0;
        else if(spi_finish) dbg_finish <= ~dbg_finish;
    end

    always @(*) begin
        case(SW[1:0])
            2'b00: begin // 기본 상태
                led_status[0] = spi_start;
                led_status[1] = dbg_finish; 
                led_status[2] = csn;
                led_status[3] = spi_MOSI;
                led_status[4] = sclk;
                led_status[5] = spi_MISO;
                led_status[6] = data_valid;
                led_status[7] = spi_ready;
                // 부호 비트가 제대로 들어오는지 LED로 확인 (깜빡이면 정상)
                led_status[8] = real_x[15]; 
                led_status[9] = real_y[15];	
            end
            
            2'b01: begin // X축 절대값 상위 비트
                led_status = abs_x[15:6]; 
            end

            2'b10: begin // Y축 절대값 상위 비트
                led_status = abs_y[15:6];
            end

            2'b11: begin // Z축 절대값 상위 비트
                led_status = abs_z[15:6];
            end
        endcase
    end
    assign LEDR = led_status;

    // =============================================================
    // [4] 7-Segment 연결 (확장된 절대값 사용)
    // =============================================================
    // HEX 값이 너무 빠르게 바뀌면 하위 비트([3:0])는 버리고 상위 비트만 봅니다.
    // 여기서는 전체를 다 봅니다.
    
    // X축
    Segment_Decoder u_sd_0(.iDATA(abs_x[8:5]),   .oDATA(HEX0)); 
    Segment_Decoder u_sd_1(.iDATA(abs_x[12:9]),   .oDATA(HEX1));

    // Y축
    Segment_Decoder u_sd_2(.iDATA(abs_y[8:5]),   .oDATA(HEX2));
    Segment_Decoder u_sd_3(.iDATA(abs_y[12:9]),   .oDATA(HEX3));

    // Z축
    Segment_Decoder u_sd_4(.iDATA(abs_z[8:5]),   .oDATA(HEX4));
    Segment_Decoder u_sd_5(.iDATA(abs_z[12:9]),   .oDATA(HEX5));







	 
		
/*	Segment_Decoder u_sd_0(.iDATA(disp_x[11:8]), .oDATA(HEX0));
	Segment_Decoder u_sd_1(.iDATA(disp_x[15:12]), .oDATA(HEX1));

	Segment_Decoder u_sd_2(.iDATA(disp_y[11:8]), .oDATA(HEX2));
	Segment_Decoder u_sd_3(.iDATA(disp_y[15:12]), .oDATA(HEX3));

	Segment_Decoder u_sd_4(.iDATA(disp_z[11:8]), .oDATA(HEX4));	
	Segment_Decoder u_sd_5(.iDATA(disp_z[15:12]), .oDATA(HEX5)); */


	 

endmodule 