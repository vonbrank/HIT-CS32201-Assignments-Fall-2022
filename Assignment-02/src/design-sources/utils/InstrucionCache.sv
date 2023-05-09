`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:24:42
// Design Name: 
// Module Name: Cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define INST_DATA_PATH "E:/Files/Source/Assignment-02-CPU-Design-Sequential/data/inst_data.txt"


module InstrucionCache(        
        input [31: 0] readAddress,
        output [31: 0] readData
    );

    reg [31: 0] instructionCache [255: 0];

    initial begin
        $readmemh(`INST_DATA_PATH , instructionCache);
    end


    assign readData = instructionCache[readAddress >> 2];

endmodule
