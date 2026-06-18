`timescale 1ns/1ps

module tb_spi_master_core;

  // =========================
  // DUT I/O
  // =========================
  reg         iclk;
  reg         irst_n;

  reg         spi_start;
  reg         frame_start;
  reg         frame_end;
  reg  [7:0]  i_byte;

  wire        spi_ready;
  wire        spi_finish;
  wire [7:0]  o_data;

  wire        spi_MOSI;
  reg         spi_MISO;
  wire        sclk;
  wire        csn;

  // =========================
  // Instantiate DUT
  // =========================
  spi_master_core dut (
    .iclk       (iclk),
    .irst_n     (irst_n),
    .spi_start  (spi_start),
    .frame_start(frame_start),
    .frame_end  (frame_end),
    .i_byte     (i_byte),
    .spi_ready  (spi_ready),
    .spi_finish (spi_finish),
    .o_data     (o_data),
    .spi_MOSI   (spi_MOSI),
    .spi_MISO   (spi_MISO),
    .sclk       (sclk),
    .csn        (csn)
  );

  // =========================
  // Clock (50 MHz -> 20 ns)
  // =========================
  initial iclk = 1'b0;
  always #10 iclk = ~iclk;

  // =========================
  // Fake SPI Slave 설정
  // =========================
  // 마스터가 보내는 MOSI 바이트 캡처
  reg [7:0] mosi_captured;
  integer   mosi_bit_idx;

  // 슬레이브가 돌려줄 응답 바이트 (MISO)
  localparam [7:0] SLAVE_REPLY = 8'hE5;
  integer miso_bit_idx;

  // Mode3(CPOL=1, CPHA=1) 가정:
  // - 마스터는 falling edge에서 MOSI 갱신
  // - 마스터는 rising edge에서 MISO 샘플
  // 그러므로 슬레이브는 "마스터 샘플(상승) 전에" MISO를 준비해야 하므로
  // 일반적으로 falling edge에서 다음 비트를 세팅해두면 안전.
  always @(negedge sclk) begin
    if (!csn) begin
      // MOSI 캡처: Mode3에서는 데이터가 보통 falling 이후 안정 -> 여기서 읽기 적합
      if (mosi_bit_idx >= 0 && mosi_bit_idx <= 7) begin
        mosi_captured[7-mosi_bit_idx] <= spi_MOSI;
      end

      // 다음 MISO 비트 준비 (MSB부터)
      if (miso_bit_idx >= 0 && miso_bit_idx <= 7) begin
        spi_MISO <= SLAVE_REPLY[7-miso_bit_idx];
      end else begin
        spi_MISO <= 1'b0;
      end

      mosi_bit_idx <= mosi_bit_idx + 1;
      miso_bit_idx <= miso_bit_idx + 1;
    end
  end

  // CS 올라가면 인덱스 리셋
  always @(posedge csn) begin
    mosi_bit_idx <= 0;
    miso_bit_idx <= 0;
    spi_MISO     <= 1'b0;
  end

  // =========================
  // Test sequence
  // =========================
  initial begin
    // init
    spi_start   = 0;
    frame_start = 0;
    frame_end   = 0;
    i_byte      = 8'h00;

    spi_MISO     = 1'b0;
    mosi_captured = 8'h00;
    mosi_bit_idx  = 0;
    miso_bit_idx  = 0;

    // reset
    irst_n = 0;
    repeat(10) @(posedge iclk);
    irst_n = 1;

    // =========================
    // 1바이트 전송 테스트
    // =========================
    wait (spi_ready == 1'b1);
    @(posedge iclk);

    i_byte      = 8'hA5;   // 마스터가 보낼 바이트
    frame_start = 1'b1;    // 프레임 시작 (CS low 기대)
    frame_end   = 1'b1;    // 이 바이트가 프레임 끝
    spi_start   = 1'b1;

    @(posedge iclk);
    spi_start   = 1'b0;
    frame_start = 1'b0;
    frame_end   = 1'b0;

    // 전송 완료 대기
    wait (spi_finish == 1'b1);
    @(posedge iclk);

    $display("MOSI sent      = 0x%02h (captured)", mosi_captured);
    $display("MISO expected  = 0x%02h", SLAVE_REPLY);
    $display("RX o_data      = 0x%02h", o_data);

    if (o_data === SLAVE_REPLY)
      $display("[PASS] 8-bit SPI RX OK");
    else
      $display("[FAIL] RX mismatch");

    // =========================
    // 추가로 한 번 더 (패턴 변경)
    // =========================
    wait (spi_ready == 1'b1);
    @(posedge iclk);

    i_byte      = 8'h3C;
    frame_start = 1'b1;
    frame_end   = 1'b1;
    spi_start   = 1'b1;

    @(posedge iclk);
    spi_start   = 1'b0;
    frame_start = 1'b0;
    frame_end   = 1'b0;

    wait (spi_finish == 1'b1);
    @(posedge iclk);

    $display("MOSI sent      = 0x%02h (captured)", mosi_captured);
    $display("RX o_data      = 0x%02h", o_data);

    // 끝
    repeat(20) @(posedge iclk);
    $finish;
  end

endmodule
