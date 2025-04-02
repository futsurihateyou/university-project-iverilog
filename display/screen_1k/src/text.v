module textEngine (
    input clk,
    input success,
    input rst_btn,
    input [9:0] pixelAddress,
    input [7:0] idata,
    output [7:0] pixelData
);
    reg [7:0] fontBuffer [1519:0];
    initial $readmemh("font.hex", fontBuffer);

    reg [7:0] textBuffer [63:0];
    reg [5:0] charCounter = 0;

    integer i;
    initial begin
        for (i=0; i<64; i=i+1) begin
            textBuffer[i] = 66;
        end
    end

    wire [5:0] charAddress;
    wire [2:0] columnAddress;
    wire topRow;

    reg [7:0] outputBuffer;

    wire [7:0] charOutput, chosenChar;
   
    always @(posedge success or negedge rst_btn) begin
        textBuffer[charCounter] <= idata;
        charCounter <= charCounter + 1;
        if (!rst_btn) begin
            for (i=0; i<64; i=i+1) begin
                textBuffer[i] = 66;
    
        end
    end

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