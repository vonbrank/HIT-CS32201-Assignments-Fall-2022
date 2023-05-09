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

/* base test */
`define INST_DATA_PATH "E:/Files/Source/Assignment-03-CPU-Design-Pipelines/data/base_test/base_inst_data"

/* additional test 1 */
// `define INST_DATA_PATH "E:/Files/Source/Assignment-03-CPU-Design-Pipelines/data/add_test1/additional_inst_data1"

/* additional test 2 */
// `define INST_DATA_PATH "E:/Files/Source/Assignment-03-CPU-Design-Pipelines/data/add_test2/additional_inst_data2"


module InstrucionCache(        
        input [31: 0] readAddress,
        output [31: 0] readData
    );

    reg [31: 0] instructionCache [255: 0];

    initial begin
        $readmemh(`INST_DATA_PATH , instructionCache);
    end


    assign readData = instructionCache[readAddress >> 2];

endmodule
