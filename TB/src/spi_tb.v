
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

wire s_ioSclk;
wire s_ioSdin;
wire s_ioCs;
wire s_ioDc;
wire s_ioReset;
wire [7:0] s_i_data;

wire m_ioSclk;
wire m_ioSdin;
wire m_ioCs;
wire m_ioDc;
wire m_ioReset;
wire [7:0] m_i_data;

wire start;

GSR GSR(.GSRI(1'b1));

m_top u_m_top
(
    .clk            ( clk           ),
    .ioSclk         ( m_ioSclk      ),
    .ioSdin         ( m_ioSdin      ),    
    .ioCs           ( m_ioCs        ),
    .ioDc           ( m_ioDc        ),
    .ioReset        ( m_ioReset     ),
    .SCLK_MASTER    ( SCLK_MASTER   ),
    .SS_N_MASTER    ( SS_N_MASTER   ),
    .MOSI_MASTER    ( MOSI_MASTER   ),
    .MISO_MASTER    ( MISO_MASTER   ),
    .btn_reset      ( m_btn_reset   ),
	.btn_send       ( btn_send      ),

    .i_data         ( m_i_data      ),
    .send (start)
);

s_top u_s_top(
    .clk            ( clk           ),
    .ioSclk         ( s_ioSclk      ),
    .ioSdin         ( s_ioSdin      ),
    .ioCs           ( s_ioCs        ),
    .ioDc           ( s_ioDc        ),
    .ioReset        ( s_ioReset     ),
    .SCLK           ( SCLK_MASTER   ),
    .MOSI           ( MOSI_MASTER   ),
    .SS             ( SS_N_MASTER   ),
    .MISO           ( MISO_MASTER   ),
    .btn_reset      ( s_btn_reset   ),

    .i_data         ( s_i_data      )
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
        #20000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #1000000;

        btn_send=0;
        #6000000;
        btn_send=1;
        #1000000;
        btn_send=0;
        #6000000;
        btn_send=1;
        #1000000;
       
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
