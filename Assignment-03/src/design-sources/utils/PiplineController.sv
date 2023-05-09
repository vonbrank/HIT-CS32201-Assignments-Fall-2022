`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/19 19:25:16
// Design Name: 
// Module Name: PiplineController
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


module PiplineController(
        input clk,
        input rst,

        input [4: 0] useRegNumber,
        input useRegEN,

        input [4: 0] releaseRegNumber,
        input releaseRegEN,

        output reg [31: 0] useRegCond
    );

    always @(posedge clk) begin
        if(!rst) begin
            useRegCond <= 32'b0;
        end
        else begin
            if(releaseRegEN && useRegEN) begin
                if(releaseRegNumber == useRegNumber) begin
                    useRegCond[releaseRegNumber] <= 1'b0;
                end
                else begin
                    useRegCond[releaseRegNumber] <= 1'b0;
                    if(useRegNumber != 1'b0)
                        useRegCond[useRegNumber] <= 1'b1;
                end
            end
            else begin
                if(releaseRegEN) begin
                    useRegCond[releaseRegNumber] <= 1'b0;
                end
                
                if(useRegEN) begin
                    if(useRegNumber != 1'b0)
                        useRegCond[useRegNumber] <= 1'b1;
                end
            end

        end
    end

    

endmodule
