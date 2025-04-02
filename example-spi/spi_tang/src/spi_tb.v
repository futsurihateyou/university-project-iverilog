`timescale 1ns / 1ns

module spi_tb();

reg clk;
reg start;

reg [7:0] data_out_m;
wire [7:0] data_in_m;

reg [7:0] data_out_s;
wire [7:0] data_in_s;

wire SCLK;
wire MOSI;
wire MISO;
wire SS;

spi_master m (clk, start, data_out_m, data_in_m, SCLK, MOSI, MISO, SS);
spi_slave s (data_out_s, data_in_s, SCLK, MOSI, MISO, SS);

initial
begin
	clk = 0;
	start = 0;
	data_out_m = 134;
	data_out_s = 79;
	
	#10 start = 1;
	#20 start = 0;
end

initial forever #5 clk = !clk;

initial #1000 $finish;

initial
begin
	$dumpfile("spi.vcd");
	$dumpvars(0, spi_tb);
end

endmodule