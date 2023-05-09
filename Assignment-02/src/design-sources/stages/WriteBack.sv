`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:05:15
// Design Name: 
// Module Name: WriteBack
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

module WriteBack(
        input clk,
        input rst,

        input EN,

        input [31: 0] ALU_Output,
        input [31: 0] LMD,
        input cond,
        input [31: 0] IR,

        output valWriteEN,
        output reg [31: 0] valWrite
    );

    wire [5: 0] iCode = IR[31: 26];
    wire [10: 0] iFun = IR[10: 0];
    reg bCurrentStage;
    reg valWriteENPre;

    always @(posedge clk) begin
        if(!rst) begin
            bCurrentStage <= 0;
        end
        else if(EN) begin
            bCurrentStage <= 1;
        end
        else begin
            bCurrentStage <= 0;
        end
    end

    always_comb begin
        if(!rst) begin
            valWrite <= 0;
            valWriteENPre <= 1'b0;
        end
        else begin
            case (iCode)
                `ALU_OP_CODE: begin
                    case(iFun)
                        `SLT_FUN_CODE: begin
                            valWrite <= {{31{1'b0}}, cond};
                            valWriteENPre <= 1'b1;
                        end 
                        `MOVZ_FUN_CODE: begin
                            valWrite <= ALU_Output;
                            valWriteENPre <= cond ? 1'b1 : 1'b0;
                        end
                        `NOP_FUN_CODE: begin
                            valWrite <= 32'b0;
                            valWriteENPre <= 1'b0;
                        end
                        default: begin
                            valWrite <= ALU_Output;
                            valWriteENPre <= 1'b1;
                        end
                    endcase
                end
                `LW_OP_CODE: begin
                    valWrite <= LMD;
                    valWriteENPre <= 1'b1;
                end
                default: begin
                    valWrite <= 32'b0;
                    valWriteENPre <= 1'b0;
                end 
            endcase
        end
    end

    assign valWriteEN = valWriteENPre & bCurrentStage;

endmodule
