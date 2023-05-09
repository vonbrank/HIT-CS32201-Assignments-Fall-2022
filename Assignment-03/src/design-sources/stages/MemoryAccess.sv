`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:04:51
// Design Name: 
// Module Name: MemoryAccess
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

`include "OperationCode.h"

module MemoryAccess(
        input clk,
        input rst,

        input [31: 0] ALU_Output,
        input [31: 0] RegB,
        input cond,
        input [31: 0] nextPC,
        input [31: 0] IR,

        output condOut,
        output reg [31: 0] LMD,
        output [31: 0] ALU_Output_Out,
        output [31: 0] IROut,


        output reg [31: 0] predictPC
    );

    wire [5: 0] iCode = IR[31: 26];
    wire [10: 0] iFun = IR[10: 0];
    
    reg writeEN;
    wire [31: 0] readData;

    assign condOut = cond;
    assign ALU_Output_Out = ALU_Output;
    assign IROut = IR;

    always @(posedge clk) begin
        if(iCode == `SW_OP_CODE) writeEN <= 1'b1;
        else writeEN <= 1'b0;
    end

    always_comb begin
        if(!rst) begin
            predictPC <= 0;
            LMD <= 0;
        end 
        else begin
            case (iCode)
                `BEQ_OP_CODE: predictPC <= cond == 1'b1 ? ALU_Output : nextPC;
                `J_OP_CODE: predictPC <= ALU_Output;
                default: begin
                    predictPC <= nextPC;
                end 
            endcase
            LMD <= readData;
        end
    end

    DataCache dataCache(
        .clk (clk),
        .rst (rst),
        .readAddress (ALU_Output),
        .readData (readData),
        .writeEN (writeEN),
        .writeAddress (ALU_Output),
        .writeData (RegB)
    );

endmodule
