`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:10:35
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    input clk ,
    input rst ,
    // READ PORT 1
    input [4 :0] readAddressA,
    output [31:0] readValA,
    // READ PORT 2
    input [4 :0] readAddressB,
    output [31:0] readValB,
    // WRITE PORT
    input writeEN , //write enable, active high
    input [4 :0] writeAddress ,
    input [31:0] writeVal
);
    reg [31:0] registers [31:1];
    reg [31:0] initalData [31:1];
    // initial with $readmemh is synthesizable here
    integer i;
    initial begin
        for(i=1; i<=31; i=i+1) initalData[i] <= 1'b0;
        registers <= initalData;
    end
    //WRITE
    always @(posedge clk) begin
        if(!rst) begin
            registers <= initalData;
        end
        else if (|writeAddress && writeEN) begin // don't write to $0
            registers[writeAddress] <= writeVal;
        end
    end
    //READ OUT 1
    assign readValA = (readAddressA == 5'b0) ? 32'b0 : registers[readAddressA];
    //READ OUT 2
    assign readValB = (readAddressB == 5'b0) ? 32'b0 : registers[readAddressB];
endmodule
