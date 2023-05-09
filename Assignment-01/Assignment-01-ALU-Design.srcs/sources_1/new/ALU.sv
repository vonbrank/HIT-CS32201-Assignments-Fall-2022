`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/16 12:28:55
// Design Name: 
// Module Name: ALU
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

`define ADD_A_B 5'b00001
`define ADD_A_B_C 5'b00010
`define SUB_A_B 5'b00011
`define SUB_A_B_C 5'b00100
`define SUB_B_A 5'b00101
`define SUB_B_A_C 5'b00110
`define EQ_A 5'b00111
`define EQ_B 5'b01000
`define NOT_A 5'b01001
`define NOT_B 5'b01010
`define ADD 5'b01011
`define MUL 5'b01100
`define NXOR 5'b01101
`define XOR 5'b01110
`define NOT_MUL 5'b01111
`define ZERO 5'b10000


module ALU(
    input [31: 0] A,
    input [31: 0] B,
    input Cin,
    input [4: 0] Card,

    output [31: 0] F,
    output Cout,
    output Zero
    );

    reg [31: 0] outF;
    reg outCout;

    always_comb begin
        case (Card)
            `ADD_A_B:   {outCout, outF} <= A + B;
            `ADD_A_B_C:   {outCout, outF} <= A + B + Cin;
            `SUB_A_B:   {outCout, outF} <= A - B;
            `SUB_A_B_C: {outCout, outF} <= A -B - Cin;
            `SUB_B_A: {outCout, outF} <= B - A;
            `SUB_B_A_C: {outCout, outF} <= B - A - Cin;
            `EQ_A: {outCout, outF} <= {1'b0, A};
            `EQ_B: {outCout, outF} <= {1'b0, B};

            `NOT_A: {outCout, outF} <= {1'b0, ~A};
            `NOT_B: {outCout, outF} <= {1'b0, ~B};
            `ADD: {outCout, outF} <= A + B;
            `MUL: {outCout, outF} <= A * B;
            `NXOR: {outCout, outF} <= {1'b0, ~(A ^ B)};
            `XOR: {outCout, outF} <= {1'b0 ,A ^ B};
            `NOT_MUL: {outCout, outF} <= ~(A * B);
            `ZERO: {outCout, outF} <= 33'b0;
            default: {outCout, outF} <= A + B;
        endcase
    end

    assign F = outF;
    assign Cout = outCout;
    assign Zero = outF == 32'b0;

endmodule
