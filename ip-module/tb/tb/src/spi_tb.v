
`timescale 1ns/1ps

module tb;

reg clk;
reg m_btn_reset;
reg s_btn_reset;
reg btn_send;

wire SCLK_MASTER;
wire SS_N_MASTER;
wire MOSI_MASTER;
wire MISO_MASTER;
wire is_sending;
wire [7:0] m_leds;

wire [7:0] s_leds;
wire is_receiveing;
wire is_transmitting;

GSR GSR(.GSRI(1'b1));

spi_master u_spi_master 
	(
      .clk(clk),
      .btn_reset(m_btn_reset),
      .btn_send(btn_send),
      .SCLK_MASTER(SCLK_MASTER),
      .SS_N_MASTER(SS_N_MASTER),
      .MOSI_MASTER(MOSI_MASTER),
      .MISO_MASTER(MISO_MASTER),  
      .leds(m_leds),
      .is_sending(is_sending)
    );

spi_slave u_spi_slave(
 .clk(clk),
 .btn_reset(s_btn_reset),
 .SCLK(SCLK_MASTER),
 .MOSI(MOSI_MASTER),
 .MISO(MISO_MASTER),
 .SS(SS_N_MASTER),
 .is_receiveing(is_receiveing),
 .is_transmitting(is_transmitting),

 .leds(s_leds)
);

    initial begin
        clk=0;
        forever #10 clk=~clk;
    end

    initial begin
        m_btn_reset=1;
        s_btn_reset=1;
        btn_send=1;		
        #2000000;
        m_btn_reset=0;
        s_btn_reset=0;
        #6000000;
        m_btn_reset=1;
        s_btn_reset=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;
		btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;
        
        #2000000;
        m_btn_reset=0;
        s_btn_reset=0;
        #6000000;
        m_btn_reset=1;
        s_btn_reset=1;
        #2000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #2000000;

        $finish;		
    end

endmodule
