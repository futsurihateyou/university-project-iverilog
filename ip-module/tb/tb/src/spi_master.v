  
`timescale 1ns/1ps

`define DATA_WIDTH 8
   
module spi_master  
	(
      clk,
      btn_reset,
	  btn_send,
      SCLK_MASTER,
      SS_N_MASTER,
      MOSI_MASTER,
      MISO_MASTER,
      leds,
      is_sending
    );
        
    input  clk;
    input  btn_reset;
	input  btn_send;
	output SCLK_MASTER;
	output SS_N_MASTER;
	output MOSI_MASTER;
	input  MISO_MASTER;
    output [7:0] leds;
    output is_sending;
            
////////////////////////////////////////////////////////////////   
// Internal Wires/Registers

 wire                      I_RESETN;
 wire                      I_TX_EN;
 wire [2:0]                I_WADDR;
 wire [`DATA_WIDTH-1:0]    I_WDATA;
 wire                      I_RX_EN;
 wire [2:0]                I_RADDR;
 wire [`DATA_WIDTH-1:0]    O_RDATA;
 
 wire                      MOSI_SLAVE;
 wire                      MISO_SLAVE;
 wire                      SS_N_SLAVE;
 wire                      SCLK_SLAVE;
 
 wire                      reset_on_1;
 wire                      reset_on_0;
 reg  [7:0]                delay_btn_reset=0;
 reg  [7:0]                delay_btn_send=0; 
 reg  [14:0]               counter0=0;
 reg                       clk_en=0; 

 reg change_rd=1;
 wire                      start; 

 reg [7:0]                 o_data=8'b11111111;

//////////////////////////////////////////////////////////////////////////
// Button debounce processing

 assign reset_on_1=&{delay_btn_reset[5],!delay_btn_reset[4],!delay_btn_reset[3],!delay_btn_reset[2],!delay_btn_reset[1],!delay_btn_reset[0]};
 
 assign reset_on_0=~reset_on_1;
 
 assign start=&{delay_btn_send[5],!delay_btn_send[4],!delay_btn_send[3],!delay_btn_send[2],!delay_btn_send[1],!delay_btn_send[0]}; 

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
	
 always @(posedge clk)
    if(clk_en==1'b1) 
	begin
       delay_btn_send[7:1] <= delay_btn_send[6:0];
       delay_btn_send[0] <= btn_send;
    end

//////////////////////////////////////////////////////////////////////////
// Data management

always @(posedge clk)
    if(reset_on_1) 
    begin
        o_data <= 8'b11111111;  
        change_rd <= 1;
    end
    else if (is_sending && change_rd)
    begin
        o_data <= o_data - 1'b1;
        change_rd <= 0;
    end
    else if (!is_sending)
        change_rd <= 1;

///////////////////////////////////////////////////////////////////////////

 m_spi_control u_spi_control (
    .I_CLK              ( clk         ),
    .I_RESETN           ( reset_on_0  ),
    .start              ( start       ),
    .I_TX_EN            ( I_TX_EN     ),
    .I_WADDR            ( I_WADDR     ),
    .I_WDATA            ( I_WDATA     ),
    .I_RX_EN            ( I_RX_EN     ),
    .I_RADDR            ( I_RADDR     ),
    .O_RDATA            ( O_RDATA     ),
	.wr_index           ( wr_index    ),

    .i_data             ( leds        ),
    .o_data             ( o_data      ),
    .is_sending         ( is_sending  )
 );

 SPI_MASTER_Top u_spi_master (
    .I_CLK              ( clk         ),
    .I_RESETN           ( reset_on_0  ),
    .I_TX_EN            ( I_TX_EN     ),
    .I_WADDR            ( I_WADDR     ),
    .I_WDATA            ( I_WDATA     ),
    .I_RX_EN            ( I_RX_EN     ),
    .I_RADDR            ( I_RADDR     ),
    .O_RDATA            ( O_RDATA     ),
    .O_SPI_INT          (             ),
    .MISO_MASTER        ( MISO_MASTER ),
    .MOSI_MASTER        ( MOSI_MASTER ),
    .SS_N_MASTER        ( SS_N_MASTER ),
    .SCLK_MASTER        ( SCLK_MASTER ),
    .MISO_SLAVE         ( MISO_SLAVE  ),
    .MOSI_SLAVE         ( MOSI_SLAVE  ),
    .SS_N_SLAVE         ( SS_N_SLAVE  ),
    .SCLK_SLAVE         ( SCLK_SLAVE  )
 );
          
endmodule
