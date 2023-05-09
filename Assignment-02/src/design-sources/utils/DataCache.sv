`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:24:42
// Design Name: 
// Module Name: Cache
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
`define DATA_PATH "E:/Files/Source/Assignment-02-CPU-Design-Sequential/data/data_data.txt"

module DataCache(
        input clk,
        input rst,
        
        input [31: 0] readAddress,
        output [31: 0] readData,

        input writeEN, 
        input [31: 0] writeAddress,
        input [31: 0] writeData

    );

    (*mark_debug = "true"*) reg [31: 0] dataCache [255: 0];
    (*mark_debug = "true"*) reg [31: 0] initialData [255: 0];

    reg [7: 0] resetAddress;

    initial begin
        $readmemh(`DATA_PATH , initialData);
        $readmemh(`DATA_PATH , dataCache);
        
        // initalData <= dataCache;
    end

    initial resetAddress = 0;

    // integer i;
    always @(posedge clk) begin 
        if(!rst) begin
            // for(i=0; i<256; i=i+1) dataCache[i] <= i;
            dataCache[resetAddress] <= initialData[resetAddress];
        end
        else if(writeEN) begin
            dataCache[writeAddress >> 2] <= writeData;
        end 

    end

    always @(posedge clk) begin 
        resetAddress <= resetAddress + 1;
    end
    

    assign readData = dataCache[readAddress >> 2];

endmodule
