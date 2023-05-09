`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/16 21:42:39
// Design Name: 
// Module Name: ALU_test
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

module ALU_test(
    );

    parameter interval = 4'd2;

    reg [31: 0] A;
    reg [31: 0] B;
    reg Cin;
    reg [4: 0] Card;

    reg [31: 0] F;
    reg Cout;
    reg Zero;

    reg [1: 0] CinCount;

    

    initial begin

        Card = 5'b1;

        while(Card != 5'b10001) begin

            CinCount = 2'b00;

            while (CinCount != 2'b10) begin
                Cin = CinCount[0];
                A = 32'd0;
                B = 32'd0;

                #interval
                A = 32'd1;
                B = 32'd1;

                #interval
                A = 32'd4;
                B = 32'd5;
                
                #interval
                A = 32'h8000_0000;
                B = 32'h8000_0000;

                #interval
                A = 32'h0FFF_FF00;
                B = 32'hF000_00FF;

                #interval
                CinCount = CinCount + 1'b1;
            end

            Card = Card + 1'b1;
        end


    end

    ALU alu(
        .A(A),
        .B(B),
        .Cin(Cin),
        .Card(Card),
        .F(F),
        .Cout(Cout),
        .Zero(Zero)
    );





endmodule
