module master_control
(
	input clk,
	input increment,
	input transmit,
	output [5:0] led,

	output SCLK,
	output MOSI,
	input MISO,
	output SS
);

reg [7:0] data_out;
wire [7:0] data_in;

reg [19:0] start_counter;
wire start;

reg [19:0] inc_counter;

spi_master m (clk, start, data_out, data_in, SCLK, MOSI, MISO, SS);

always @(posedge clk)
begin
	if (!increment)
	begin
		if (!inc_counter[19])
		begin
			inc_counter = inc_counter + 1;
			if (inc_counter[19]) 
				data_out = data_out + 1;
		end
	end
	else
	begin
		inc_counter <= 0;
	end
end

always @(posedge clk)
begin
	if (!transmit)
	begin
		if (!start_counter[19])
			start_counter <= start_counter + 1;
	end
	else
	begin
		start_counter <= 0;
	end
end

assign led = ~data_out[5:0];
assign start = start_counter[19];

endmodule