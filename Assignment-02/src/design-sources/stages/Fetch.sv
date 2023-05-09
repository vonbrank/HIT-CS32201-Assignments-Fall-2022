`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 18:57:46
// Design Name: 
// Module Name: Fetch
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


module Fetch(
        input clk,
        input rst,

        input [31: 0] predictPC,

        output [31: 0] NPC,
        output [31: 0] IR,
        output [31: 0] PC
    );

    assign PC = rst ? predictPC : 32'h0000_0000;
    assign NPC = PC + 4;

    InstrucionCache instructionCache(
        .readAddress(PC), 
        .readData(IR)
    );

endmodule
