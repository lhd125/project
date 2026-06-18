module spi_4wire_FSM(
    input wire          iclk,
    input wire          irstn,
    input wire          spi_ready,
    input wire          spi_finish,
    input wire [SO_DataL:0]   idata,
    input wire         	ig_int2,

    output reg          spi_start,
    output reg         frame_start,
    output reg         frame_end,
    output reg [SO_DataL:0]  odata,

    //3-axis accelerometer interface
    output reg [SI_DataL:0]   data_x,
    output reg [SI_DataL:0]   data_y,
    output reg [SI_DataL:0]   data_z,
    output reg         		  data_valid,
    output reg [7:0]   int_source);

    `include "spi_4wire.h"

    reg [2:0] state;
    reg [3:0] number;
    reg [SI_DataL-2:0] write_data;
    reg [2:0] byte_cnt; // read/write byte 구분용
    reg [22:0] wait_cnt;
    reg [20:0] boot_cnt;
    reg flag;
    reg done;
    reg init_done;
    always @(number) begin
        case(number)
            // [1. 기본 설정 (0~1)]
            4'd0:  write_data = {DATA_FORMAT,  VAL_FORMAT_16G};
            4'd1:  write_data = {BW_RATE,      8'h07};

            // [2. TAP(충격) 설정 (2~6)]
            4'd2:  write_data = {THRESH_TAP,   VAL_THRESH_TAP};
            4'd3:  write_data = {DUR,          VAL_DUR};
            4'd4:  write_data = {LATENT,       VAL_LATENT};
            4'd5:  write_data = {WINDOW,       VAL_WINDOW};
            4'd6:  write_data = {TAP_AXES,     VAL_TAP_AXES_XYZ};

            // [3. Free Fall(낙하) 설정 (7~8)] -> (새로 추가됨!)
            // THRESH_FF: 0x09 * 62.5mg = 약 0.56g (이보다 작으면 낙하로 간주)
            4'd7:  write_data = {THRESH_FF,    VAL_THRESH_FF}; 
            // TIME_FF: 0x10(16) * 5ms = 80ms (이 시간 동안 유지되어야 함)
            4'd8:  write_data = {TIME_FF,      VAL_TIME_FF_100MS};

            // [4. 인터럽트 설정 (9~10)]
            // 기존 7,8번이 9,10번으로 밀림
            4'd9:  write_data = {INT_MAP,      8'h04};   
            4'd10: write_data = {INT_ENABLE,   8'h64}; // Tap + FreeFall 활성화

            // [5. 측정 모드 켜기 (11)]
            // 마지막 인덱스 11번에서 최종적으로 센서를 깨움
            4'd11: write_data = {POWER_CTL,    VAL_POWER_CTL_MEASURE};

            default: write_data = {POWER_CTL,  VAL_POWER_CTL_MEASURE}; 
        endcase
    end
    
    always@(posedge iclk or negedge irstn) begin    
        if(~irstn) begin
            number <= 4'd0;
            odata  <= 8'd0;
            frame_start <= 1'b0;
            frame_end <= 1'b0;
            spi_start <= 1'b0;
            byte_cnt    <= 3'd0;
            wait_cnt    <= 23'd0;
            data_valid  <= 1'b0;
            data_x <= 0; data_y <= 0; data_z <= 0;
            flag <= 1'b0;
			boot_cnt <= 0;
            init_done   <= 1'b0;
            done       <= 1'b0;
            state <= IDLE;
        end else begin
            if(spi_start) spi_start  <= 1'b0;
            if(!flag) begin
                frame_start <= 1'b0;
                frame_end   <= 1'b0;
            end
            data_valid      <= 1'b0;
            case(state)
                IDLE: begin
						flag <= 1'b0;
                  wait_cnt <= 23'd0;
					if(!init_done) begin
                        if(boot_cnt < 21'd1_000_000) begin
                            boot_cnt <= boot_cnt + 1;
                            state    <= IDLE;
                        end else begin
                            init_done <= 1'b1; 
                            boot_cnt  <= 0;
                        end
                    end	  
                    if(number <= INI_NUMBER) begin
                        if(spi_ready) state <= TRANSFER;
                        else state <= IDLE;
                    end
                    else begin
                        //if(number == 4'd15) number <= 4'd0;
                        if(ig_int2 && spi_ready) begin
                            state <= INT;
                            byte_cnt <= 3'd0;
                         end

                        else if(done && spi_ready) begin
                            state <= FINISH; 
                            byte_cnt <= 0; 
                            done <= 0;
                        end
                      
                        else begin
                            state <= DELAY;
                        end     
                    end 
                end
                TRANSFER: begin
                    if(spi_ready && !flag) begin
                        spi_start <= 1'b1;
                        flag <= 1'b1;
                        if(byte_cnt == 0) begin // write mode
                            odata <= {WRITE_MODE, write_data[SI_DataL-2:8]}; // high byte first
                            //byte_cnt <= 1'b1;
                            frame_start <= 1'b1; // csn low
                        end else begin 
                            odata 	<=  write_data[7:0];
                            frame_end <= 1'b1; // low byte transfer
                        end
                    end
                    if(spi_finish) begin
                        flag <= 1'b0;
                        if(byte_cnt == 0) begin
                            byte_cnt <= 1;
                        end
                        else begin
                            /*byte_cnt <= 0;
                            number <= number + 1;
                            flag <= 1'b0;
                            state <= IDLE;*/
                        end 
                    end
                    if(byte_cnt == 1 && !flag && !spi_start) begin
                        if(wait_cnt < 23'd1000) begin
                            wait_cnt <= wait_cnt + 1;
                        end 
                        else begin
                            wait_cnt <= 0;
                            byte_cnt <= 0; 
                            number <= number + 1;
                            state <= IDLE;
                        end
                    end
                end
                INT: begin
                    if(spi_ready && !flag) begin
                        spi_start <= 1'b1;
                        flag <= 1'b1;
                        if(byte_cnt == 3'd0) begin
                            odata <= {READ_MODE, INT_SOURCE};
                            frame_start <= 1'b1;
                        end else begin
                            odata <= 8'h0; // dummy byte
                            frame_end <= 1'b1;
                        end
                    end
                    if(spi_finish) begin
                        flag <= 1'b0;
                        if(byte_cnt == 0) begin
                            byte_cnt <= 1;
                        end
                        else begin
                            int_source <= idata[7:0];
                            byte_cnt <= 0;
                            flag <= 1'b0;
                            state <= IDLE;
                        end
                    end
                end
                DELAY: begin
                    if(wait_cnt >= 23'd5_000_000) begin // 100ms 대기
                        wait_cnt <= 0;
                        byte_cnt <= 0;
                        flag <= 1'b0;
                        state  <= FINISH;
                    end else begin
                        wait_cnt <= wait_cnt + 1;
                    end
                end
                FINISH: begin
                    if(spi_ready && !flag) begin
                        spi_start <= 1'b1;
                        flag <= 1'b1;
                        if(byte_cnt == 3'd0) begin
                            odata <= 8'hF2;
                            frame_start <= 1'b1;
                        end else begin
                            odata <= 8'h00; // dummy byte
                            if(byte_cnt == 3'd6) begin
                            frame_end <= 1'b1;
                            end
                        end
                    end
                    if(spi_finish) begin
								flag <= 1'b0;
        
        // 첫 번째 바이트(ID)를 받으면 X축 데이터 자리에 넣어서 HEX에 띄움
								if(byte_cnt == 3'd0) begin
									byte_cnt <= byte_cnt + 1; // 상위 비트는 0으로
								end
                                else begin
                                    case(byte_cnt)
                                        3'd1: data_x[7:0]   <= idata; // DATAX0
                                        3'd2: data_x[SI_DataL:8] <= idata; // DATAX1
                                        3'd3: data_y[7:0]   <= idata; // DATAY0
                                        3'd4: data_y[SI_DataL:8] <= idata; // DATAY1
                                        3'd5: data_z[7:0]   <= idata; // DATAZ0
                                        3'd6: data_z[SI_DataL:8] <= idata; // DATAZ1
                                    endcase
                                    if (byte_cnt == 3'd6) begin
                                        data_valid <= 1'b1;
                                        byte_cnt   <= 3'd0;
                                        state      <= IDLE;
                                        end                     
                                    else begin
                                        byte_cnt <= byte_cnt + 1; // 카운터가 0인 경우 활성하
                                    end
                                end
                                    
                                end
                            end
					endcase
				end
			end
									
endmodule
