	/*------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Bo Young Kang, All rights reserved.
 *
 *  File name  : fully_connected.v
 *  Written by : Kang, Bo Young
 *  Written on : Oct 13, 2021
 *  Version    : 21.2
 *  Design     : Fully Connected Layer for CNN
 *
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  Module: fully_connected
 *------------------------------------------------------------------*/

 module fc_1ch #(parameter DATA_BIT = 12, WEIGHT_BIT = 8, ACCUM_BIT = 32, ADDR_BIT = 10, TOTAL_INPUT = 144) (
   input wire clk,
   input wire rst_n,
   input wire valid_in,
   input wire skip_enable,
   input wire signed [DATA_BIT-1:0] data_in,
   output reg [ADDR_BIT-1:0] weight_addr,
   output reg weight_en,
   input wire signed [WEIGHT_BIT-1:0] weight_in,
   output reg signed [ACCUM_BIT-1:0] data_out,
   output reg valid_out_fc
 );
 reg signed [ACCUM_BIT-1:0] accumulator;
 reg signed [DATA_BIT-1:0] data_buffer;
 reg mac_en1;

 always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        valid_out_fc <= 0;
        mac_en1 <= 0;
        accumulator <= 0;
        data_buffer <= 0;
        weight_addr <= 0;
        weight_en <= 0;
    end
    else begin
        if(valid_in) begin
            data_buffer <= data_in;
            weight_addr <= weight_addr + 1;
            if(skip_enable) begin
                weight_en <= 0;
                mac_en1 <= 0;
            end
            else begin
                weight_en <= 1;
                mac_en1 <= 1;
            end
        end
        else begin
            weight_en <= 0;
            mac_en1 <= 0;
        end
        valid_out_fc <= 0;
        if(mac_en1) begin
            accumulator <= accumulator + (data_buffer * weight_in);
        end
        if(weight_addr == 0) begin
            valid_out_fc <= 1;
            data_out <= accumulator + (data_buffer * weight_in);
        end
    end
end

 endmodule