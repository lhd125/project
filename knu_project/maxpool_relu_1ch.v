module maxpool_relu_1ch #(
    parameter CONV_BIT = 12,         // 데이터 비트 폭 (예: 12-bit)
    parameter HALF_WIDTH = 14,       // 풀링 후 가로 픽셀 수 (28x28 입력 시 14)
    parameter HALF_WIDTH_BIT = 4     // pcount를 위한 비트 수 (14를 표현하려면 4-bit 필요)
)(
    input wire clk,
    input wire rst_n,
    input wire valid_in,
    input wire signed [CONV_BIT-1:0] conv_out,
    output reg valid_out_relu,
    output reg signed [CONV_BIT-1:0] max_value,
    output reg zero_skip
);
    reg signed [CONV_BIT-1:0] buffer [0:HALF_WIDTH-1]; // line buffer
    reg [HALF_WIDTH_BIT-1:0] pcount;
    reg state;
    reg flag;

    wire signed [CONV_BIT-1:0] max_temp = (buffer[pcount] < conv_out) ? conv_out : buffer[pcount];
    always @(posedge clk) begin
        if (~rst_n) begin
            valid_out_relu <= 0;
            pcount <= 0;
            state <= 0;
            flag <= 0;
            max_value <= 0;
            zero_skip <= 0;
        end else begin
            if (valid_in) begin
                flag <= ~flag;
                if (flag) begin
                    pcount <= pcount + 1;
                    if (pcount == HALF_WIDTH - 1) begin
                        state <= ~state;
                        pcount <= 0;
                    end
                end

                if (state == 0) begin // first line
                    valid_out_relu <= 0;
                    if (!flag) begin // first input
                        buffer[pcount] <= conv_out;
                    end else begin // second input -> comparison
                        buffer[pcount] <= max_temp;
                    end
                end else begin // second line
                    if (!flag) begin // third input -> comparison
                        valid_out_relu <= 0;
                        buffer[pcount] <= max_temp;
                    end else begin
                        valid_out_relu <= 1;
                        max_value <= (max_temp > 0) ? max_temp : 0; // ReLU activation
                        zero_skip <= (max_temp <= 0) ? 1'b1 : 1'b0; //
                    end
                end
            end else begin
                valid_out_relu <= 0; // No valid input, reset output valid signal
            end
        end
    end
endmodule