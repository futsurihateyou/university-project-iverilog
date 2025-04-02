`timescale  1ns / 1ps

module spi_slave (
 clk,
 btn_reset,
 SCLK,
 MOSI,
 MISO,
 SS,
 is_receiveing,
 is_transmitting,
 leds
);

 input clk;
 input btn_reset;
 input SCLK;
 input MOSI;
 input SS;
 output MISO;
 output is_receiveing;
 output is_transmitting; 
 output reg [7:0] leds;
 
///////////////////////////////////////////////////////////////////////////
// Internal Wires/Registers

 wire                      reset_on_1;
 reg  [7:0]                delay_btn_reset=0;
 reg  [14:0]               counter0=0;
 reg                       clk_en=0; 

 reg                       transmit_rd=0;

 reg [7:0] o_data = 8'b11111111;
 wire [7:0] i_data;

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
// Data management

always @(negedge is_receiveing)
    leds <= i_data;

always @(posedge clk)
    if (reset_on_1)
        o_data <= 8'b11111111;
    else if (!transmit_rd && !is_transmitting)
    begin
        o_data <= o_data - 1'b1;
        transmit_rd <= 1;
    end    
    else if (is_transmitting)
        transmit_rd <= 0;  

//////////////////////////////////////////////////////////////////////////

s_spi_control u_spi_control(
 .SCLK(SCLK),
 .MOSI(MOSI),
 .MISO(MISO),
 .SS(SS),
 
 .i_data(i_data),
 .o_data(o_data),
 .is_receiveing(is_receiveing),
 .is_transmitting(is_transmitting)
);  

endmodule
