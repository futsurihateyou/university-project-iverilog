module slave
#(
    localparam LEN_DATA = 8
)
(
input SCLK, 
input MOSI, 
input SS,
output reg MISO
);
  
    reg [2:0] counter = 3'b0;
    reg [LEN_DATA - 1:0] data_s = 6'b111111;

    always @ (negedge SCLK)
    begin
      if(!SS)
        begin
          if (counter < LEN_DATA)
          begin  
              counter = counter + 1;
              MISO = data_s[0];
              data_s = data_s >> 1;
              data_s[LEN_DATA - 1] = MOSI;
          end
          else 
          begin
              counter = 0;  
          end  
        end
    end
endmodule