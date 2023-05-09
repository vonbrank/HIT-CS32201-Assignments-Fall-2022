`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 18:52:52
// Design Name: 
// Module Name: StageController
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


module StageController(
        input clk ,
        input rst ,

        output reg bFetchStage,
        output reg bDecodeStage,
        output reg bExecuteStage,
        output reg bMemoryStage,
        output reg bWriteBackStage
    );

    (*mark_debug = "true"*) reg [2: 0] counter;

    // counter 在 rst 为 0 时 = 0，否则按 1 2 3 4 5 循环

    always @(posedge clk) begin
        if(!rst) counter <= {3{1'b0}};
        else begin 
            if(counter == 5) counter <= 1;
            else counter = counter + 1;
        end
    end

    always @(negedge clk) begin
        bFetchStage <= counter == 1;
        bDecodeStage <= counter == 2;
        bExecuteStage <= counter == 3;
        bMemoryStage <= counter == 4;
        bWriteBackStage <= counter == 5;
    end


endmodule
