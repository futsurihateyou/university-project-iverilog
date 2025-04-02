module spi_master
(
	input clk,
	input start,
	input [7:0] data_out,
	output reg [7:0] data_in,

	output reg SCLK,
	output reg MOSI,
	input MISO,
	output reg SS
);

reg [1:0] state;
reg [2:0] data_counter;

initial
begin
	data_in <= 0;
	state <= 0;
	SS <= 1;
	MOSI <= 0;
	SCLK <= 0;
	data_counter <= 0;
end

always @(posedge clk)
begin
	case (state)
		0:
		begin
			if (start) // If not transmitting but commanded to start
			begin
				state <= 1;

				SS <= 0;
				SCLK <= 0;
				data_counter <= 7;
				MOSI <= data_out[7];
			end
		end
		1: // If transmitting
		begin
			if (!SCLK) // If making a posedge
			begin		
				data_in[data_counter] <= MISO;

				if (!data_counter)
					state <= 2;
				else
					data_counter <= data_counter - 1'b1;
			end
			else
			begin
				MOSI <= data_out[data_counter];
			end

			SCLK <= ~SCLK;
		end
		2: // If packets sent
		begin
			SCLK <= 0;
			state <= 3;
			MOSI <= 0;
		end
		3: // If ending transmission
		begin
			SS <= 1;
			state <= 0;
		end
	endcase
end

endmodule