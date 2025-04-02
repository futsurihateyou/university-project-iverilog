module top
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,
    output SCLK,
    output ioSdin,
    output ioCs,
    output ioDc,
    output ioReset,
    input rst_btn,
    input data_btn
   //дописать порты spi и вызвать ниже

);
    reg [7:0] idata;
    wire success;
    wire [9:0] pixelAddress;
    wire [7:0] pixelData;
    reg [7:0] textBuffer [63:0];
    reg [5:0] charCounter=0;
    reg [6:0] ir = 0;
    reg [3:0] ff = 0;
    reg flag_rst = 0;

    integer i;
    initial begin
        for (i=0; i<64; i=i+1) begin
            textBuffer[i] = 0;
        end
    end

    screen #(STARTUP_WAIT) scr(
        clk, 
        SCLK, 
        ioSdin, 
        ioCs, 
        ioDc, 
        ioReset, 
        pixelAddress,
        pixelData,
        rst_btn// если надо могу удалить перезапуск
    );

    
    integer i;

    always @(posedge success) begin
        textBuffer[charCounter] <= idata;
        charCounter <= charCounter + 1;
        if (!rst) begin
            for (i=0; i<64; i=i+1) begin
            textBuffer[i] = 0;
        end
            charCounter <=0;
        end
    end

    assign rst = charCounter ? rst_btn : 1;

    reg [7:0] fontBuffer [1519:0];
    initial $readmemh("font.hex", fontBuffer);

    wire [5:0] charAddress;
    wire [2:0] columnAddress;
    wire topRow;

    reg [7:0] outputBuffer;

    wire [7:0] charOutput, chosenChar;
   
    always @(posedge clk) begin
        outputBuffer <= fontBuffer[((chosenChar-8'd32) << 4) + (columnAddress << 1) + (topRow ? 0 : 1)];
    end

    assign charAddress = {pixelAddress[9:8],pixelAddress[6:3]};
    assign columnAddress = pixelAddress[2:0];
    assign topRow = !pixelAddress[7];

    assign charOutput = textBuffer[charAddress];    
    assign chosenChar = (charOutput >= 32 && charOutput <= 126) ? charOutput : 32;

    assign pixelData = outputBuffer;
endmodule