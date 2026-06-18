//=======================================================
//  ADXL345 Parameters Header File (spi_param.h)
//=======================================================

//-------------------------------------------------------
// 1. Bit Width & State Definition
//-------------------------------------------------------
parameter   SI_DataL        =   15;     // Total Command Width (16-bit)
parameter   SO_DataL        =   7;      // Data Width (8-bit)

// SPI FSM States
parameter   IDLE            =   3'b000;
parameter   DELAY           =   3'b001;
parameter   TRANSFER        =   3'b010;
parameter   FINISH          =   3'b011;
parameter   INT             =   3'b100;
    

// counter
parameter INI_NUMBER        =   4'd11;

//-------------------------------------------------------
// 2. SPI Command Modes (Top 2 Bits: [15:14])
//-------------------------------------------------------
parameter   WRITE_MODE      =   2'b00;  // Write, Single Byte
parameter   READ_MODE       =   2'b10;  // Read, Single Byte
parameter   MULTI_MODE      =   2'b11;  // Read, Multi-Byte (Burst)

//-------------------------------------------------------
// 3. Register Addresses (6-Bits: [13:8])
//-------------------------------------------------------
parameter   DEVID           =   6'h00;  
parameter   THRESH_TAP      =   6'h1D;  
parameter   OFSX            =   6'h1E;  
parameter   OFSY            =   6'h1F;  
parameter   OFSZ            =   6'h20;  
parameter   DUR             =   6'h21;  
parameter   LATENT          =   6'h22;  
parameter   WINDOW          =   6'h23;  
parameter   THRESH_ACT      =   6'h24;  
parameter   THRESH_INACT    =   6'h25;  
parameter   TIME_INACT      =   6'h26;  
parameter   ACT_INACT_CTL   =   6'h27;  
parameter   THRESH_FF       =   6'h28;  
parameter   TIME_FF         =   6'h29;  
parameter   TAP_AXES        =   6'h2A;  
parameter   ACT_TAP_STATUS  =   6'h2B;  
parameter   BW_RATE         =   6'h2C;  
parameter   POWER_CTL       =   6'h2D;  
parameter   INT_ENABLE      =   6'h2E;  
parameter   INT_MAP         =   6'h2F;  
parameter   INT_SOURCE      =   6'h30;  
parameter   DATA_FORMAT     =   6'h31;  
parameter   DATAX0          =   6'h32;  
parameter   DATAX1          =   6'h33;  
parameter   DATAY0          =   6'h34;  
parameter   DATAY1          =   6'h35;  
parameter   DATAZ0          =   6'h36;  
parameter   DATAZ1          =   6'h37;  
parameter   FIFO_CTL        =   6'h38;  
parameter   FIFO_STATUS     =   6'h39;  

//-------------------------------------------------------
// 4. Configuration Data Values (8-Bits: [7:0])
//-------------------------------------------------------

// [Data Format 0x31] 4-wire SPI, Full Resolution
parameter   VAL_FORMAT_2G   = 8'h08; // +/- 2g
parameter   VAL_FORMAT_4G   = 8'h09; // +/- 4g
parameter   VAL_FORMAT_8G   = 8'h0A; // +/- 8g
parameter   VAL_FORMAT_16G  = 8'h0B; // +/- 16g

// [Power Control 0x2D]
parameter   VAL_POWER_CTL_MEASURE = 8'h08; // Measurement Mode

// [Bandwidth Rate 0x2C]
parameter   VAL_BW_RATE_100HZ     = 8'h0A; // 100Hz (Default)
parameter   VAL_BW_RATE_50HZ      = 8'h09; // 50Hz (Slow)
parameter   VAL_BW_RATE_200HZ     = 8'h0B; // 200Hz (Fast)
parameter   VAL_BW_RATE_25HZ     = 8'h08; // 25Hz (slower)

// ------------------------------------------------------
// [Tap & Activity Control Values] (Calculated from Datasheet)
// ------------------------------------------------------

// [THRESH_TAP 0x1D] Scale: 62.5 mg/LSB
// 0x30 = 48 decimal -> 48 * 0.0625 = 3.0g
parameter   VAL_THRESH_TAP        = 8'h30; // 3.0g Threshold

// [DUR 0x21] Scale: 625 us/LSB
// 0x10 = 16 decimal -> 16 * 0.625ms = 10ms
parameter   VAL_DUR               = 8'h10; // Max tap duration 10ms

// [LATENT 0x22] Scale: 1.25 ms/LSB
// 0x10 = 16 decimal -> 16 * 1.25ms = 20ms
parameter   VAL_LATENT            = 8'h10; // Wait 20ms before detecting double tap

// [WINDOW 0x23] Scale: 1.25 ms/LSB
// 0x40 = 64 decimal -> 64 * 1.25ms = 80ms
parameter   VAL_WINDOW            = 8'h40; // Window 80ms for second tap
// 0xFF = 255 decimal -> 318.75ms (Wide window)
parameter   VAL_WINDOW_WIDE       = 8'hFF; 

// [TAP_AXES 0x2A] Axis Control for Tap/Double Tap
// Bit 3: Suppress, Bit 2: X-Tap, Bit 1: Y-Tap, Bit 0: Z-Tap
// 0x07 = 0000_0111 -> Enable Tap Detection on X, Y, Z
parameter   VAL_TAP_AXES_XYZ      = 8'h07; // Enable X, Y, Z
parameter   VAL_TAP_AXES_Z_ONLY   = 8'h01; // Enable Z only

// [THRESH_ACT 0x24] Scale: 62.5 mg/LSB
// 0x20 = 32 decimal -> 32 * 0.0625 = 2.0g
parameter   VAL_THRESH_ACT        = 8'h20; // 2.0g Activity Threshold

// [THRESH_INACT 0x25] Scale: 62.5 mg/LSB
// 0x03 = 3 decimal -> 3 * 0.0625 = ~0.2g
parameter   VAL_THRESH_INACT      = 8'h03; // 0.1875g Inactivity Threshold

// [TIME_INACT 0x26] Scale: 1 sec/LSB
// 0x01 = 1 second
parameter   VAL_TIME_INACT        = 8'h01; 

// [ACT_INACT_CTL 0x27]
// 0x7F = AC coupled, Enable all axes for Act/Inact
parameter   VAL_ACT_INACT_CTL     = 8'h7F; 

// ------------------------------------------------------
// [Free-Fall Control Values] (Calculated from Datasheet)
// ------------------------------------------------------

// [THRESH_FF 0x28] Scale: 62.5 mg/LSB
// Recommended: 0.3g ~ 0.6g
// 0x06 = 6 * 0.0625 = 0.375g
// 0x09 = 9 * 0.0625 = 0.5625g
parameter   VAL_THRESH_FF         = 8'h08; // 0.5g (Commonly used)

// [TIME_FF 0x29] Scale: 5 ms/LSB
// Recommended: 100ms ~ 350ms
// 0x14 = 20 * 5ms = 100ms
// 0x28 = 40 * 5ms = 200ms
// 0x46 = 70 * 5ms = 350ms (Conservative)
parameter   VAL_TIME_FF_100MS     = 8'h14; // 100ms (Sensitive)
parameter   VAL_TIME_FF_200MS     = 8'h28; // 200ms (Balanced)
parameter   VAL_TIME_FF_350MS     = 8'h46; // 350ms (Robust)