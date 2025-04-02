module spi_slave
(
	input [7:0] data_out,
	output reg [7:0] data_in,

	input SCLK,
	input MOSI,
	output reg MISO,
	input SS
);

reg [1:0] state;
reg [2:0] data_counter;

initial
begin
	data_in <= 0;
	state <= 0;
	MISO <= 0;
	data_counter <= 0;
end

always @(negedge SCLK)
begin
	if (state == 1)
		MISO <= data_out[data_counter];
end

always @(posedge SCLK or negedge SS)
begin
	case (state)
		0:
		begin
			if (!SS)
			begin
				state <= 1;

				data_counter <= 7;
				//MISO <= data_out[7];
			end
		end
		1: // If transmitting
		begin
			data_in[data_counter] <= MOSI;

			if (!data_counter)
				state <= 2;
			else
				data_counter <= data_counter - 1;
		end
		2: // If ending transmission
		begin
			state <= 0;
			//MISO <= 0;
		end
	endcase
end

endmodule