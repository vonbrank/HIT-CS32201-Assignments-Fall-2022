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

        input [31: 0] ALU_Output,
        input [31: 0] LMD,
        input cond,
        input [31: 0] IR,

        output valWriteEN,
        output reg [31: 0] valWrite,

        output reg [4: 0] RegCAddress,
        output [4: 0] releaseRegNumber, // 即将解除占用的寄存器编号
        output releaseRegEN // 是否需要解除占用寄存器
    );

    wire [5: 0] iCode = IR[31: 26];
    wire [10: 0] iFun = IR[10: 0];
    reg valWriteENPre;

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

    always_comb begin
        if(!rst) begin
            RegCAddress <= 32'b0;
        end
        else begin
            case (iCode)
                `ALU_OP_CODE: begin
                    RegCAddress <= IR[15: 11];
                end 
                `SW_OP_CODE, `LW_OP_CODE, `BEQ_OP_CODE: begin
                    RegCAddress <= IR[20: 16];
                end 
                `J_OP_CODE: begin
                    RegCAddress <= 32'b0;
                end 
                default: begin
                    RegCAddress <= 32'b0;
                end 
            endcase
        end
    end

    assign valWriteEN = valWriteENPre;
    assign releaseRegEN = valWriteEN;
    assign releaseRegNumber =   (iCode == `ALU_OP_CODE) ? IR[25: 21] : 
                                (iCode == `LW_OP_CODE)  ? IR[20: 16] : 5'd0;

endmodule
