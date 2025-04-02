module slave_control
(
	output [5:0] led,

	input SCLK,
	input MOSI,
	output MISO,
	input SS
);

reg [7:0] data_out;
wire [7:0] data_in;

spi_slave s (data_out, data_in, SCLK, MOSI, MISO, SS);

assign led = ~data_in[5:0];

endmodule