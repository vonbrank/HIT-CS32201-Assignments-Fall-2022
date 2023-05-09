`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:02:36
// Design Name: 
// Module Name: Execute
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


module Execute(
        input clk,
        input rst,

        input [31: 0] NPC,
        input [31: 0] RegA,
        input [31: 0] RegB,
        input [31: 0] Imm,
        input [31: 0] IR,

        output [31: 0] IROut,
        output reg [31: 0] ALU_Output,
        output [31: 0] RegBOut,
        output reg cond,
        output [31: 0] NPCOut
    );

    reg [31: 0] OP1;
    reg [31: 0] OP2;

    wire [5: 0] iCode;

    assign iCode = IR[31: 26];
    assign RegBOut = RegB;
    assign IROut = IR;
    assign NPCOut = NPC;

    always_comb begin
        case (iCode) // iCode
            `ALU_OP_CODE: begin
                case(IR[10: 0]) // iFun
                    `ADD_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end 
                    `SUB_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end 
                    `AND_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end 
                    `OR_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end 
                    `XOR_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end 
                    `SLT_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end 
                    `MOVZ_FUN_CODE: begin
                        OP1 <= RegA;
                        OP2 <= 32'b0;
                    end
                    default: begin
                        OP1 <= RegA;
                        OP2 <= RegB;
                    end
                endcase
            end
            `SW_OP_CODE, `LW_OP_CODE: begin
                OP1 <= RegA;
                OP2 <= 32'b0 + Imm[15: 0];
            end 
            `BEQ_OP_CODE: begin
                OP1 <= NPC;
                OP2 <= 32'b0 + (Imm[15: 0] << 2);
            end
            `J_OP_CODE: begin
                OP1 <= {32{1'b0}};
                OP2 <= 32'b0 + {NPC[31: 28], Imm[25: 0] << 2};
            end 
            default: begin
                OP1 <= {32{1'b0}};
                OP2 <= {32{1'b0}};
            end 
        endcase  
    end

    always_comb begin
        if(!rst) begin
            ALU_Output <= 32'b0;
            cond <= 0;
        end
        else begin
            case (iCode) // iCode
                `ALU_OP_CODE: begin
                    case(IR[10: 0]) // iFun
                        `ADD_FUN_CODE: begin
                            ALU_Output <= OP1 + OP2;
                            cond <= 0;
                        end 
                        `SUB_FUN_CODE: begin
                            ALU_Output <= OP1 - OP2;
                            cond <= 0;
                        end 
                        `AND_FUN_CODE: begin
                            ALU_Output <= OP1 & OP2;
                            cond <= 0;
                        end 
                        `OR_FUN_CODE: begin
                            ALU_Output <= OP1 | OP2;
                            cond <= 0;
                        end 
                        `XOR_FUN_CODE: begin
                            ALU_Output <= OP1 ^ OP2;
                            cond <= 0;
                        end 
                        `SLT_FUN_CODE: begin
                            ALU_Output <= {32{1'b0}};
                            cond <= OP1 < OP2 ? 1'b1 : 1'b0;
                        end 
                        `MOVZ_FUN_CODE: begin
                            ALU_Output <= OP1;
                            cond <= RegB == 32'b0 ? 1 : 0;
                        end
                        default: begin
                            ALU_Output <= OP1 + OP2;
                            cond <= 0;
                        end
                    endcase
                end
                `SW_OP_CODE, `LW_OP_CODE: begin
                    ALU_Output <= OP1 + OP2;
                    cond <= 0;
                end 
                `BEQ_OP_CODE: begin
                    ALU_Output <= OP1 + OP2;
                    cond <= RegA == RegB ? 1'b1 : 1'b0;
                end
                `J_OP_CODE: begin
                    ALU_Output <= OP1 + OP2;
                    cond <= 0;
                end 
                default: begin
                    ALU_Output <= OP1 + OP2;
                    cond <= 0;
                end 
            endcase          
        end
    end

endmodule
