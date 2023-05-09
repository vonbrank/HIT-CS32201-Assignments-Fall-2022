`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 18:59:36
// Design Name: 
// Module Name: Decode
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


module Decode(
        input clk,
        input rst,

        input [31: 0] NPC,
        input [31: 0] IR,

        input writeEN,
        input [31: 0] writeVal,

        input [31: 0] useRegCond, // 寄存器是否占用
        input [31: 0] regWriteAddress,

        output [31: 0] NPCOut,
        output [31: 0] RegA,
        output [31: 0] RegB,
        output reg [31: 0] Imm,
        output [31: 0] IROut,

        output [4: 0] useRegNumber, // 即将使用的寄存器编号
        output useRegEN, // 是否需要使用寄存器
        output stall
    );

    reg [4: 0] RegCAddress;

    wire [5: 0] iCode;
    assign iCode = IR[31: 26];

    always_comb begin
        if(!rst) begin
            Imm <= {32{1'b0}};
            RegCAddress <= 32'b0;
        end
        else begin
            case (iCode)
                `ALU_OP_CODE: begin
                    Imm <= {21'b0, IR[10: 0]};   // 运算类
                    RegCAddress <= IR[15: 11];
                end 
                `SW_OP_CODE, `LW_OP_CODE, `BEQ_OP_CODE: begin
                    Imm <= {{16{IR[15]}}, IR[15: 0]}; // 访存类， BEQ
                    RegCAddress <= IR[20: 16];
                end 
                `J_OP_CODE: begin
                    Imm <= {5'b0, IR[26: 0]};
                    RegCAddress <= 32'b0;
                end 
                default: begin
                    Imm <= {5'b0, IR[26: 0]}; // J
                    RegCAddress <= 32'b0;
                end 
            endcase
        end
    end

    assign NPCOut = NPC;
    assign IROut = IR;


    assign useRegEN = !stall ? (iCode == `ALU_OP_CODE || iCode == `LW_OP_CODE) : 1'b0;
    assign useRegNumber =   (iCode == `ALU_OP_CODE) ? IR[25: 21] : 
                            (iCode == `LW_OP_CODE)  ? IR[20: 16] : 5'd0;
    assign stall = useRegNumber == 5'd0 ? 1'b0 : 
                                    (
                                        (iCode == `ALU_OP_CODE) && (useRegCond[useRegNumber] || useRegCond[IR[20: 16]] || useRegCond[IR[15: 11]]) ||
                                        ((iCode == `LW_OP_CODE) && (useRegCond[useRegNumber] || useRegCond[IR[25: 21]])) ||
                                        (iCode == `SW_OP_CODE) && (useRegCond[IR[25: 21]] || useRegCond[IR[20: 16]]) ||
                                        (iCode == `BEQ_OP_CODE) && (useRegCond[IR[25: 21]] || useRegCond[IR[20: 16]])
                                    ); // 当将使用的寄存器发生占用时插入气泡


    RegisterFile registerFile(
        .clk (clk),
        .rst (rst),
        .readAddressA (IR[25: 21]),
        .readValA (RegA),
        .readAddressB (IR[20: 16]),
        .readValB (RegB),
        .writeEN (writeEN),
        .writeAddress (regWriteAddress),
        .writeVal (writeVal)
    );

    assign currentRegWriteAddress = RegCAddress;

endmodule
