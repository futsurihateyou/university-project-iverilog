`timescale 1ns/1ps

`define STARTUP_WAIT 32'd10000000

module s_top
(
    clk,
    ioSclk,
    ioSdin,
    ioCs,
    ioDc,
    ioReset,
    SCLK,
    MOSI,
    SS,
    MISO,
    btn_reset,

    i_data
);

    input clk;
    output ioSclk;
    output ioSdin;
    output ioCs;
    output ioDc;
    output ioReset;
    input SCLK;
    input MOSI;
    input SS;
    output MISO;
    input  btn_reset;

    output [7:0] i_data;

////////////////////////////////////////////////////////////////   
// Internal Wires/Registers
    
    // For buttons
    wire                      reset_on_1;
    reg  [7:0]                delay_btn_reset=0;
    reg  [14:0]               counter0=0;
    reg                       clk_en=0; 

    // For data
    reg  [7:0]                i_message [63:0];
    reg  [7:0]                o_message [63:0];
    reg  [7:0]                o_data=0;
    //wire [7:0]                i_data;
    reg  [5:0]                i_index=0;
    reg  [5:0]                o_index=0;
    reg                       transmit_rd=0;
    reg                       receive_rd=0;
    wire                      is_transmitting;
    wire                      is_receiveing;

    
    // For display
    reg [7:0]                 fontBuffer [1519:0];

    wire [9:0]                pixelAddress;
    wire [7:0]                pixelData;
    
    wire [5:0]                charAddress;
    wire [2:0]                columnAddress;
    wire                      topRow;
    
    reg  [7:0]                outputBuffer;
    wire [7:0]                charOutput;
    wire [7:0]                chosenChar;
 
////////////////////////////////////////////////////////////////   
// Initial
 
    integer i;
    initial begin
        $readmemh("font.hex", fontBuffer);

        for (i=0; i<64; i=i+1) begin
            i_message[i] = 0;
        end

        o_message[0] = "F";
        o_message[1] = "R";
        o_message[2] = "O";
        o_message[3] = "M";
        o_message[4] = " ";
        o_message[5] = "S";
        o_message[6] = "L";
        o_message[7] = "A";
        o_message[8] = "V";
        o_message[9] = "E";
        for (i=10; i<64; i=i+1) begin
            o_message[i] = 0;
        end
    end

//////////////////////////////////////////////////////////////////////////
// Button debounce processing

 assign reset_on_1=&{delay_btn_reset[5],!delay_btn_reset[4],!delay_btn_reset[3],!delay_btn_reset[2],!delay_btn_reset[1],!delay_btn_reset[0]};

 always @(posedge clk) 
    if(counter0==15'd26999) 
	begin
	   counter0 <= 15'd0;
	   clk_en <= 1'b1;
	end
	else begin
	   counter0 <= counter0 + 15'd1;
	   clk_en <= 1'b0;	 
	end
    
 always @(posedge clk)
    if(clk_en==1'b1) 
	begin
       delay_btn_reset[7:1] <= delay_btn_reset[6:0];
       delay_btn_reset[0] <= btn_reset;
    end

//////////////////////////////////////////////////////////////////////////
// Output data preparation

always @(posedge clk)
    if (reset_on_1)
    begin
        o_data <= o_message[0];
        o_index <= 1;

        transmit_rd <= 0;
    end
    // Data transmited and needs to be updated
    else if (!is_transmitting && transmit_rd)
    begin
        o_data <= o_message[o_index];
        o_index <= o_index + 1;

        transmit_rd <= 0;
    end    
    else if (is_transmitting)
        transmit_rd <= 1;

////////////////////////////////////////////////////////////////  
// Input data management

always @(posedge clk)
    if (reset_on_1)
    begin
        for (i=0; i<64; i=i+1) 
          begin
            i_message[i] <= 0;
          end
        i_index <=0; 
        
        receive_rd <= 0;
    end
    // Data received and ready for display
    else if (!is_receiveing && receive_rd)
    begin
        i_message[i_index] <= i_data;
        i_index <= i_index + 1;
        
        if (!i_index)
        begin
        for (i=1; i<64; i=i+1) 
          begin
            i_message[i] <= 0;
          end
        end

        receive_rd <= 0;
    end
    else if (is_receiveing)
        receive_rd <= 1;

////////////////////////////////////////////////////////////////   
// Preparation for display
 
    always @(posedge clk) begin
        outputBuffer <= fontBuffer[((chosenChar-8'd32) << 4) + (columnAddress << 1) + (topRow ? 0 : 1)];
    end

    assign charAddress = {pixelAddress[9:8],pixelAddress[6:3]};
    assign columnAddress = pixelAddress[2:0];
    assign topRow = !pixelAddress[7];

    assign charOutput = i_message[charAddress];    
    assign chosenChar = (charOutput >= 32 && charOutput <= 126) ? charOutput : 32;

    assign pixelData = outputBuffer;

///////////////////////////////////////////////////////////////////////////

s_screen u_m_screen (
    .clk                ( clk               ), 
    .ioSclk             ( ioSclk            ), 
    .ioSdin             ( ioSdin            ), 
    .ioCs               ( ioCs              ), 
    .ioDc               ( ioDc              ), 
    .ioReset            ( ioReset           ), 
    .pixelAddress       ( pixelAddress      ),
    .pixelData          ( pixelData         ),
    .rst_btn            ( btn_reset         )
);

s_spi_control u_spi_control(
 .SCLK                  ( SCLK              ),
 .MOSI                  ( MOSI              ),
 .MISO                  ( MISO              ),
 .SS                    ( SS                ),
    
 .i_data                ( i_data            ),
 .o_data                ( o_data            ),
 .is_receiveing         ( is_receiveing     ),
 .is_transmitting       ( is_transmitting   )
); 

endmodule