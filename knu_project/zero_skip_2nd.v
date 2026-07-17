module zeroskip_layer (
   input clk,
   input rst_n,
   input valid_in,
   input [11:0] max_value_1, max_value_2, max_value_3,
   output [11:0] conv2_out_1, conv2_out_2, conv2_out_3,
   output  valid_out_conv2,
   input [0:199] w_211,
   input [0:199] w_212,
   input [0:199] w_213,
   input [0:199] w_221,
   input [0:199] w_222,
   input [0:199] w_223,
   input [0:199] w_231,
   input [0:199] w_232,
   input [0:199] w_233,
   input [0:23] b_2
 );

 localparam CHANNEL_LEN = 3;
 ///////////////////////////////////////////
 // Channel 1
 wire [11:0] data_out1_0, data_out1_1, data_out1_2, data_out1_3, data_out1_4,
  data_out1_5, data_out1_6, data_out1_7, data_out1_8, data_out1_9,
  data_out1_10, data_out1_11, data_out1_12, data_out1_13, data_out1_14,
  data_out1_15, data_out1_16, data_out1_17, data_out1_18, data_out1_19,
  data_out1_20, data_out1_21, data_out1_22, data_out1_23, data_out1_24;
 wire valid_out1_buf;

 // Channel 2
 wire [11:0] data_out2_0, data_out2_1, data_out2_2, data_out2_3, data_out2_4,
  data_out2_5, data_out2_6, data_out2_7, data_out2_8, data_out2_9,
  data_out2_10, data_out2_11, data_out2_12, data_out2_13, data_out2_14,
  data_out2_15, data_out2_16, data_out2_17, data_out2_18, data_out2_19,
  data_out2_20, data_out2_21, data_out2_22, data_out2_23, data_out2_24;
 wire valid_out2_buf;

 // Channel 3 
 wire [11:0] data_out3_0, data_out3_1, data_out3_2, data_out3_3, data_out3_4,
  data_out3_5, data_out3_6, data_out3_7, data_out3_8, data_out3_9,
  data_out3_10, data_out3_11, data_out3_12, data_out3_13, data_out3_14,
  data_out3_15, data_out3_16, data_out3_17, data_out3_18, data_out3_19,
  data_out3_20, data_out3_21, data_out3_22, data_out3_23, data_out3_24;
 wire valid_out3_buf;

 wire signed [13:0] conv_out_1, conv_out_2, conv_out_3;
 wire valid_out_buf, valid_out_calc_1, valid_out_calc_2, valid_out_calc_3;
 assign valid_out_buf = valid_out1_buf & valid_out2_buf & valid_out3_buf;
 assign valid_out_conv2 = valid_out_calc_1 & valid_out_calc_2 & valid_out_calc_3;
 wire [0:299] flat_data1, flat_data2, flat_data3;
 

 reg signed [7:0] bias [0:CHANNEL_LEN - 1];
 wire signed [11:0] exp_bias [0:CHANNEL_LEN - 1];

 assign flat_data1 = {data_out1_0, data_out1_1, data_out1_2, data_out1_3, data_out1_4, data_out1_5, data_out1_6, data_out1_7, data_out1_8, data_out1_9,
                     data_out1_10, data_out1_11, data_out1_12, data_out1_13, data_out1_14,
                     data_out1_15, data_out1_16, data_out1_17, data_out1_18, data_out1_19,
                     data_out1_20, data_out1_21, data_out1_22, data_out1_23, data_out1_24};
 assign flat_data2 = {data_out2_0, data_out2_1, data_out2_2, data_out2_3, data_out2_4, data_out2_5, data_out2_6, data_out2_7, data_out2_8, data_out2_9,
                     data_out2_10, data_out2_11, data_out2_12, data_out2_13, data_out2_14,
                     data_out2_15, data_out2_16, data_out2_17, data_out2_18, data_out2_19,
                     data_out2_20, data_out2_21, data_out2_22, data_out2_23, data_out2_24};
 assign flat_data3 = {data_out3_0, data_out3_1, data_out3_2, data_out3_3, data_out3_4, data_out3_5, data_out3_6, data_out3_7, data_out3_8, data_out3_9,
                     data_out3_10, data_out3_11, data_out3_12, data_out3_13, data_out3_14,
                     data_out3_15, data_out3_16, data_out3_17, data_out3_18, data_out3_19,
                     data_out3_20, data_out3_21, data_out3_22, data_out3_23, data_out3_24};


zeroskip_buf #(.WIDTH(24), .HEIGHT(24), .DATA_BITS(12)) zeroskip_buf_1(
   .clk(clk),
   .rst_n(rst_n),
   .valid_in(valid_in),
   .data_in(max_value_1),
   .data_out_0(data_out1_0), .data_out_1(data_out1_1), .data_out_2(data_out1_2), .data_out_3(data_out1_3), .data_out_4(data_out1_4),
   .data_out_5(data_out1_5), .data_out_6(data_out1_6), .data_out_7(data_out1_7), .data_out_8(data_out1_8), .data_out_9(data_out1_9),
   .data_out_10(data_out1_10), .data_out_11(data_out1_11), .data_out_12(data_out1_12), .data_out_13(data_out1_13), .data_out_14(data_out1_14),
   .data_out_15(data_out1_15), .data_out_16(data_out1_16), .data_out_17(data_out1_17), .data_out_18(data_out1_18), .data_out_19(data_out1_19),
   .data_out_20(data_out1_20), .data_out_21(data_out1_21), .data_out_22(data_out1_22), .data_out_23(data_out1_23), .data_out_24(data_out1_24),
   .valid_out_buf(valid_out1_buf)
 );

 zeroskip_buf #(.WIDTH(24), .HEIGHT(24), .DATA_BITS  (12)) zeroskip_buf_2(
   .clk(clk),
   .rst_n(rst_n),
   .valid_in(valid_in),
   .data_in(max_value_2),
   .data_out_0(data_out2_0), .data_out_1(data_out2_1), .data_out_2(data_out2_2), .data_out_3(data_out2_3), .data_out_4(data_out2_4),
   .data_out_5(data_out2_5), .data_out_6(data_out2_6), .data_out_7(data_out2_7), .data_out_8(data_out2_8), .data_out_9(data_out2_9),
   .data_out_10(data_out2_10), .data_out_11(data_out2_11), .data_out_12(data_out2_12), .data_out_13(data_out2_13), .data_out_14(data_out2_14),
   .data_out_15(data_out2_15), .data_out_16(data_out2_16), .data_out_17(data_out2_17), .data_out_18(data_out2_18), .data_out_19(data_out2_19),
   .data_out_20(data_out2_20), .data_out_21(data_out2_21), .data_out_22(data_out2_22), .data_out_23(data_out2_23), .data_out_24(data_out2_24),
   .valid_out_buf(valid_out2_buf)
 );

 zeroskip_buf #(.WIDTH(24), .HEIGHT(24), .DATA_BITS(12)) zeroskip_buf_3(
   .clk(clk),
   .rst_n(rst_n),
   .valid_in(valid_in),
   .data_in(max_value_3),
   .data_out_0(data_out3_0), .data_out_1(data_out3_1), .data_out_2(data_out3_2), .data_out_3(data_out3_3), .data_out_4(data_out3_4),
   .data_out_5(data_out3_5), .data_out_6(data_out3_6), .data_out_7(data_out3_7), .data_out_8(data_out3_8), .data_out_9(data_out3_9),
   .data_out_10(data_out3_10), .data_out_11(data_out3_11), .data_out_12(data_out3_12), .data_out_13(data_out3_13), .data_out_14(data_out3_14),
   .data_out_15(data_out3_15), .data_out_16(data_out3_16), .data_out_17(data_out3_17), .data_out_18(data_out3_18), .data_out_19(data_out3_19),
   .data_out_20(data_out3_20), .data_out_21(data_out3_21), .data_out_22(data_out3_22), .data_out_23(data_out3_23), .data_out_24(data_out3_24),
   .valid_out_buf(valid_out3_buf)   
 );

zeroskip_calc conv2_calc_1(
   .clk(clk),
   .rst_n(rst_n),
   .valid_out_buf(valid_out_buf),
   .data_in1(flat_data1),
   .data_in2(flat_data2),
    .data_in3(flat_data3),
   .data_out(conv_out_1),
   .valid_out_calc(valid_out_calc_1),
   .w_1(w_211),
  .w_2(w_212),
  .w_3(w_213)
);

zeroskip_calc conv2_calc_2(
   .clk(clk),
   .rst_n(rst_n),
   .valid_out_buf(valid_out_buf),
   .data_in1(flat_data1),
   .data_in2(flat_data2),
   .data_in3(flat_data3),
   .data_out(conv_out_2),
   .valid_out_calc(valid_out_calc_2),
   .w_1(w_221),
  .w_2(w_222),
  .w_3(w_223)   
);

zeroskip_calc conv2_calc_3(
   .clk(clk),
   .rst_n(rst_n),
   .valid_out_buf(valid_out_buf),
   .data_in1(flat_data1),
   .data_in2(flat_data2),
   .data_in3(flat_data3),
   .data_out(conv_out_3),
   .valid_out_calc(valid_out_calc_3),
   .w_1(w_231),
  .w_2(w_232),
  .w_3(w_233)   
);


integer i;
always @(*) begin
    for(i=0;i<=2;i=i+1) begin
        bias[i]=b_2[(8*i)+:8];
    end
end
 assign exp_bias[0] = (bias[0][7] == 1) ? {4'b1111, bias[0]} : {4'b0000, bias[0]};
 assign exp_bias[1] = (bias[1][7] == 1) ? {4'b1111, bias[1]} : {4'b0000, bias[1]};
 assign exp_bias[2] = (bias[2][7] == 1) ? {4'b1111, bias[2]} : {4'b0000, bias[2]};

 assign conv2_out_1 = conv_out_1[13:1] + exp_bias[0];
 assign conv2_out_2 = conv_out_2[13:1] + exp_bias[1];
 assign conv2_out_3 = conv_out_3[13:1] + exp_bias[2];
 
 endmodule

 // ==========================================
 // zeroskip_buf 모듈 (수정 없이 원본 동일 유지)
 // ==========================================
 module zeroskip_buf #(parameter WIDTH = 24, HEIGHT = 24, DATA_BITS = 12) (
   input clk,
   input rst_n,
   input valid_in,
   input [DATA_BITS - 1:0] data_in,
   output reg [DATA_BITS - 1:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4,
   data_out_5, data_out_6, data_out_7, data_out_8, data_out_9,
   data_out_10, data_out_11, data_out_12, data_out_13, data_out_14,
   data_out_15, data_out_16, data_out_17, data_out_18, data_out_19,
   data_out_20, data_out_21, data_out_22, data_out_23, data_out_24,
   output reg valid_out_buf
 );

 localparam FILTER_SIZE = 5;
 
 reg [DATA_BITS - 1:0] buffer [0:WIDTH * FILTER_SIZE - 1];
 reg [DATA_BITS - 1:0] buf_idx;
 reg [4:0] w_idx, h_idx;
 reg [2:0] buf_flag;  // 0 ~ 4
 reg state;

 always @(posedge clk) begin
   if(~rst_n) begin
     buf_idx <= 0;
     w_idx <= 0;
     h_idx <= 0;
     buf_flag <= 0;
     state <= 0;
     valid_out_buf <= 0;
     data_out_0 <= 12'bx; data_out_1 <= 12'bx; data_out_2 <= 12'bx; data_out_3 <= 12'bx; data_out_4 <= 12'bx;
     data_out_5 <= 12'bx; data_out_6 <= 12'bx; data_out_7 <= 12'bx; data_out_8 <= 12'bx; data_out_9 <= 12'bx;
     data_out_10 <= 12'bx; data_out_11 <= 12'bx; data_out_12 <= 12'bx; data_out_13 <= 12'bx; data_out_14 <= 12'bx;
     data_out_15 <= 12'bx; data_out_16 <= 12'bx; data_out_17 <= 12'bx; data_out_18 <= 12'bx; data_out_19 <= 12'bx;
     data_out_20 <= 12'bx; data_out_21 <= 12'bx; data_out_22 <= 12'bx; data_out_23 <= 12'bx; data_out_24 <= 12'bx;
   end else begin
   if(valid_in) begin
     buf_idx <= buf_idx + 1'b1;
     if(buf_idx == WIDTH * FILTER_SIZE - 1) begin // buffer size = 140 = 28(w) * 5(h)
       buf_idx <= 0;
     end

     buffer[buf_idx] <= data_in;  // data input

     // Wait until first 140 input data filled in buffer
     if(!state) begin
       if(buf_idx == WIDTH * FILTER_SIZE - 1) begin
         state <= 1;
       end
     end else begin // valid state
       w_idx <= w_idx + 1'b1; // move right

      if(w_idx == WIDTH - FILTER_SIZE + 1) begin
        valid_out_buf <= 1'b0;  // unvalid area
      end else if(w_idx == WIDTH - 1) begin
        buf_flag <= buf_flag + 1;
        if(buf_flag == FILTER_SIZE - 1) begin
          buf_flag <= 0;
        end

        w_idx <= 0;

        if(h_idx == HEIGHT - FILTER_SIZE) begin // done 1 input read -> 28 * 28
          h_idx <= 0;
          state <= 0;
        end
          h_idx <= h_idx + 1;

      end else if(w_idx == 0) begin
        valid_out_buf <= 1'b1;  // start valid area
      end

      // Buffer Selection -> 5 * 5
     if(buf_flag == 3'd0) begin
       data_out_0 <= buffer[w_idx]; data_out_1 <= buffer[w_idx + 1]; data_out_2 <= buffer[w_idx + 2]; data_out_3 <= buffer[w_idx + 3]; data_out_4 <= buffer[w_idx + 4];
       data_out_5 <= buffer[w_idx + WIDTH]; data_out_6 <= buffer[w_idx + 1 + WIDTH]; data_out_7 <= buffer[w_idx + 2 + WIDTH]; data_out_8 <= buffer[w_idx + 3 + WIDTH]; data_out_9 <= buffer[w_idx + 4 + WIDTH];
       data_out_10 <= buffer[w_idx + WIDTH * 2]; data_out_11 <= buffer[w_idx + 1 + WIDTH * 2]; data_out_12 <= buffer[w_idx + 2 + WIDTH * 2]; data_out_13 <= buffer[w_idx + 3 + WIDTH * 2]; data_out_14 <= buffer[w_idx + 4 + WIDTH * 2];
       data_out_15 <= buffer[w_idx + WIDTH * 3]; data_out_16 <= buffer[w_idx + 1 + WIDTH * 3]; data_out_17 <= buffer[w_idx + 2 + WIDTH * 3]; data_out_18 <= buffer[w_idx + 3 + WIDTH * 3]; data_out_19 <= buffer[w_idx + 4 + WIDTH * 3];
       data_out_20 <= buffer[w_idx + WIDTH * 4]; data_out_21 <= buffer[w_idx + 1 + WIDTH * 4]; data_out_22 <= buffer[w_idx + 2 + WIDTH * 4]; data_out_23 <= buffer[w_idx + 3 + WIDTH * 4]; data_out_24 <= buffer[w_idx + 4 + WIDTH * 4];
     end else if(buf_flag == 3'd1) begin
       data_out_0 <= buffer[w_idx + WIDTH]; data_out_1 <= buffer[w_idx + 1 + WIDTH]; data_out_2 <= buffer[w_idx + 2 + WIDTH]; data_out_3 <= buffer[w_idx + 3 + WIDTH]; data_out_4 <= buffer[w_idx + 4 + WIDTH];
       data_out_5 <= buffer[w_idx + WIDTH * 2]; data_out_6 <= buffer[w_idx + 1 + WIDTH * 2]; data_out_7 <= buffer[w_idx + 2 + WIDTH * 2]; data_out_8 <= buffer[w_idx + 3 + WIDTH * 2]; data_out_9 <= buffer[w_idx + 4 + WIDTH * 2];
       data_out_10 <= buffer[w_idx + WIDTH * 3]; data_out_11 <= buffer[w_idx + 1 + WIDTH * 3]; data_out_12 <= buffer[w_idx + 2 + WIDTH * 3]; data_out_13 <= buffer[w_idx + 3 + WIDTH * 3]; data_out_14 <= buffer[w_idx + 4 + WIDTH * 3];
       data_out_15 <= buffer[w_idx + WIDTH * 4]; data_out_16 <= buffer[w_idx + 1 + WIDTH * 4]; data_out_17 <= buffer[w_idx + 2 + WIDTH * 4]; data_out_18 <= buffer[w_idx + 3 + WIDTH * 4]; data_out_19 <= buffer[w_idx + 4 + WIDTH * 4];
       data_out_20 <= buffer[w_idx]; data_out_21 <= buffer[w_idx + 1]; data_out_22 <= buffer[w_idx + 2]; data_out_23 <= buffer[w_idx + 3]; data_out_24 <= buffer[w_idx + 4];
     end else if(buf_flag == 3'd2) begin
       data_out_0 <= buffer[w_idx + WIDTH * 2]; data_out_1 <= buffer[w_idx + 1 + WIDTH * 2]; data_out_2 <= buffer[w_idx + 2 + WIDTH * 2]; data_out_3 <= buffer[w_idx + 3 + WIDTH * 2]; data_out_4 <= buffer[w_idx + 4 + WIDTH * 2];
       data_out_5 <= buffer[w_idx + WIDTH * 3]; data_out_6 <= buffer[w_idx + 1 + WIDTH * 3]; data_out_7 <= buffer[w_idx + 2 + WIDTH * 3]; data_out_8 <= buffer[w_idx + 3 + WIDTH * 3]; data_out_9 <= buffer[w_idx + 4 + WIDTH * 3];
       data_out_10 <= buffer[w_idx + WIDTH * 4]; data_out_11 <= buffer[w_idx + 1 + WIDTH * 4]; data_out_12 <= buffer[w_idx + 2 + WIDTH * 4]; data_out_13 <= buffer[w_idx + 3 + WIDTH * 4]; data_out_14 <= buffer[w_idx + 4 + WIDTH * 4];
       data_out_15 <= buffer[w_idx]; data_out_16 <= buffer[w_idx + 1]; data_out_17 <= buffer[w_idx + 2]; data_out_18 <= buffer[w_idx + 3]; data_out_19 <= buffer[w_idx + 4];
       data_out_20 <= buffer[w_idx + WIDTH]; data_out_21 <= buffer[w_idx + 1 + WIDTH]; data_out_22 <= buffer[w_idx + 2 + WIDTH]; data_out_23 <= buffer[w_idx + 3 + WIDTH]; data_out_24 <= buffer[w_idx + 4 + WIDTH];
     end else if(buf_flag == 3'd3) begin
       data_out_0 <= buffer[w_idx + WIDTH * 3]; data_out_1 <= buffer[w_idx + 1 + WIDTH * 3]; data_out_2 <= buffer[w_idx + 2 + WIDTH * 3]; data_out_3 <= buffer[w_idx + 3 + WIDTH * 3]; data_out_4 <= buffer[w_idx + 4 + WIDTH * 3];
       data_out_5 <= buffer[w_idx + WIDTH * 4]; data_out_6 <= buffer[w_idx + 1 + WIDTH * 4]; data_out_7 <= buffer[w_idx + 2 + WIDTH * 4]; data_out_8 <= buffer[w_idx + 3 + WIDTH * 4]; data_out_9 <= buffer[w_idx + 4 + WIDTH * 4];
       data_out_10 <= buffer[w_idx]; data_out_11 <= buffer[w_idx + 1]; data_out_12 <= buffer[w_idx + 2]; data_out_13 <= buffer[w_idx + 3]; data_out_14 <= buffer[w_idx + 4];
       data_out_15 <= buffer[w_idx + WIDTH]; data_out_16 <= buffer[w_idx + 1 + WIDTH]; data_out_17 <= buffer[w_idx + 2 + WIDTH]; data_out_18 <= buffer[w_idx + 3 + WIDTH]; data_out_19 <= buffer[w_idx + 4 + WIDTH];
       data_out_20 <= buffer[w_idx + WIDTH * 2]; data_out_21 <= buffer[w_idx + 1 + WIDTH * 2]; data_out_22 <= buffer[w_idx + 2 + WIDTH * 2]; data_out_23 <= buffer[w_idx + 3 + WIDTH * 2]; data_out_24 <= buffer[w_idx + 4 + WIDTH * 2];      
     end else if(buf_flag == 3'd4) begin
       data_out_0 <= buffer[w_idx + WIDTH * 4]; data_out_1 <= buffer[w_idx + 1 + WIDTH * 4]; data_out_2 <= buffer[w_idx + 2 + WIDTH * 4]; data_out_3 <= buffer[w_idx + 3 + WIDTH * 4]; data_out_4 <= buffer[w_idx + 4 + WIDTH * 4];
       data_out_5 <= buffer[w_idx]; data_out_6 <= buffer[w_idx + 1]; data_out_7 <= buffer[w_idx + 2]; data_out_8 <= buffer[w_idx + 3]; data_out_9 <= buffer[w_idx + 4];
       data_out_10 <= buffer[w_idx + WIDTH]; data_out_11 <= buffer[w_idx + 1 + WIDTH]; data_out_12 <= buffer[w_idx + 2 + WIDTH]; data_out_13 <= buffer[w_idx + 3 + WIDTH]; data_out_14 <= buffer[w_idx + 4 + WIDTH];
       data_out_15 <= buffer[w_idx + WIDTH * 2]; data_out_16 <= buffer[w_idx + 1 + WIDTH * 2]; data_out_17 <= buffer[w_idx + 2 + WIDTH * 2]; data_out_18 <= buffer[w_idx + 3 + WIDTH * 2]; data_out_19 <= buffer[w_idx + 4 + WIDTH * 2];
       data_out_20 <= buffer[w_idx + WIDTH * 3]; data_out_21 <= buffer[w_idx + 1 + WIDTH * 3]; data_out_22 <= buffer[w_idx + 2 + WIDTH * 3]; data_out_23 <= buffer[w_idx + 3 + WIDTH * 3]; data_out_24 <= buffer[w_idx + 4 + WIDTH * 3];   
     end
     end
   end
 end
 end
endmodule

// ==========================================
// 🚀 완벽하게 교체된 zeroskip_calc 모듈 🚀
// ==========================================
module zeroskip_calc (
    input clk,
    input rst_n,
    input valid_out_buf,
    input [0:299] data_in1,
    input [0:299] data_in2,
    input [0:299] data_in3,
    input [0:199] w_1,
    input [0:199] w_2,
    input [0:199] w_3,
    output reg signed [13:0] data_out,
    output reg valid_out_calc
);

    // 오버플로우 방지를 위한 넉넉한 26비트 누산기 선언
    reg signed [25:0] sum;
    integer i;

    // 1클럭 만에 25개의 픽셀을 병렬로 처리하는 Combinational MUX 방식의 Zero-skip
    always @(*) begin
        sum = 26'sd0;
        
        for (i = 0; i < 25; i = i + 1) begin
            // 데이터가 0이 아닐 때만 덧셈 수행 (칩 합성 시 MUX로 변환되어 Zero-power 달성)
            if (data_in1[(12*i) +: 12] != 12'sd0) begin
                sum = sum + ($signed(data_in1[(12*i) +: 12]) * $signed(w_1[(8*i) +: 8]));
            end
            if (data_in2[(12*i) +: 12] != 12'sd0) begin
                sum = sum + ($signed(data_in2[(12*i) +: 12]) * $signed(w_2[(8*i) +: 8]));
            end
            if (data_in3[(12*i) +: 12] != 12'sd0) begin
                sum = sum + ($signed(data_in3[(12*i) +: 12]) * $signed(w_3[(8*i) +: 8]));
            end
        end
    end

    // Sequential Logic: 파이프라인 동기화
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 14'sd0;
            valid_out_calc <= 1'b0;
        end 
        else begin
            if (valid_out_buf) begin
                // 이전 코드에서 사용하셨던 [19:6] 비트 스케일링 그대로 적용
                data_out <= sum[19:6]; 
                valid_out_calc <= 1'b1; // 버퍼에서 valid가 뜬 바로 다음 클럭에 정확하게 결과값 출력
            end 
            else begin
                valid_out_calc <= 1'b0;
            end
        end
    end
endmodule
