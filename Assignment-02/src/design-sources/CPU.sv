`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/25 19:09:53
// Design Name: 
// Module Name: CPU
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


module CPU(
        (*mark_debug = "true"*) input clk , // clock, 100MHz
        (*mark_debug = "true"*) input resetn , // active low
        // debug signals
        (*mark_debug = "true"*) output [31:0] debug_wb_pc , // 当前正在执行指令的 PC
        (*mark_debug = "true"*) output debug_wb_rf_wen , // 当前通用寄存器组的写使能信号
        (*mark_debug = "true"*) output [4 :0] debug_wb_rf_addr, // 当前通用寄存器组写回的寄存器编号
        (*mark_debug = "true"*) output [31:0] debug_wb_rf_wdata // 当前指令需要写回的数据
    );

    (*mark_debug = "true"*) wire valWriteEN;
    (*mark_debug = "true"*) wire [31: 0] valWrite;

    (*mark_debug = "true"*) wire bFetchStage;
    (*mark_debug = "true"*) wire bDecodeStage;
    (*mark_debug = "true"*) wire bExecuteStage;
    (*mark_debug = "true"*) wire bMemoryStage;
    (*mark_debug = "true"*) wire bWriteBackStage;

    StageController stageController(
        .clk (clk),
        .rst (resetn),
        .bFetchStage (bFetchStage),
        .bDecodeStage (bDecodeStage),
        .bExecuteStage (bExecuteStage),
        .bMemoryStage (bMemoryStage),
        .bWriteBackStage (bWriteBackStage)
    );

    reg [31: 0] IF_PC;

    wire [31: 0] MemoryAccessOutNPC;

    always @(posedge clk) begin
        if(!resetn) begin
            IF_PC <= 0;
        end
        else if(bFetchStage) begin
            IF_PC <= MemoryAccessOutNPC;
        end
    end

    wire [31: 0] FetchOutNPC;
    wire [31: 0] FetchOutIR;

    Fetch fetch(
        .clk (clk),
        .rst (resetn),

        .predictPC (IF_PC),

        .NPC    (FetchOutNPC),
        .IR     (FetchOutIR),
        .PC     (debug_wb_pc)
    );

    reg [31: 0] IF_ID_NPC;
    reg [31: 0] IF_ID_IR;

    always @(posedge clk) begin
        if(!resetn) begin
            IF_ID_NPC <= 0;
            IF_ID_IR <= 0;
        end
        else if(bDecodeStage) begin
            IF_ID_NPC <= FetchOutNPC;
            IF_ID_IR <= FetchOutIR;
        end
    end


    wire [31: 0] DecodeOutNPC;
    wire [31: 0] DecodeOutRegA;
    wire [31: 0] DecodeOutRegB;
    wire [31: 0] DecodeOutImm;
    wire [31: 0] DecodeOutIR;

    Decode decode(
        .clk (clk),
        .rst (resetn),

        .NPC (IF_ID_NPC),
        .IR (IF_ID_IR),

        .writeEN (valWriteEN),
        .writeVal (valWrite),

        .NPCOut (DecodeOutNPC),
        .RegA   (DecodeOutRegA),
        .RegB   (DecodeOutRegB),
        .Imm    (DecodeOutImm),
        .IROut  (DecodeOutIR),

        .debug_wb_rf_addr (debug_wb_rf_addr)
    );

    reg [31: 0] ID_EX_NPC;
    reg [31: 0] ID_EX_RegA;
    reg [31: 0] ID_EX_RegB;
    reg [31: 0] ID_EX_Imm;
    reg [31: 0] ID_EX_IR;

    always @(posedge clk) begin
        if(!resetn) begin
            ID_EX_NPC <= 0;
            ID_EX_RegA <= 0;
            ID_EX_RegB <= 0;
            ID_EX_Imm <= 0;
            ID_EX_IR <= 0;
        end
        else if(bExecuteStage) begin
            ID_EX_NPC <= DecodeOutNPC;
            ID_EX_RegA <= DecodeOutRegA;
            ID_EX_RegB <= DecodeOutRegB;
            ID_EX_Imm <= DecodeOutImm;
            ID_EX_IR <= DecodeOutIR;
        end
    end

    wire [31: 0] ExecuteOutIR;
    wire [31: 0] ExecuteOut_ALU_Output;
    wire [31: 0] ExecuteOutRegB;
    wire         ExecuteOutCond;
    wire [31: 0] ExecuteOutNPC;

    Execute execute(
        .clk (clk),
        .rst (resetn),

        .NPC (ID_EX_NPC),
        .RegA (ID_EX_RegA),
        .RegB (ID_EX_RegB),
        .Imm (ID_EX_Imm),
        .IR (ID_EX_IR),

        .IROut      (ExecuteOutIR),
        .ALU_Output (ExecuteOut_ALU_Output),
        .RegBOut    (ExecuteOutRegB),
        .cond       (ExecuteOutCond),
        .NPCOut     (ExecuteOutNPC)
    );

    reg [31: 0] EX_MEM_IR;
    reg [31: 0] EX_MEM_ALU_Output;
    reg [31: 0] EX_MEM_RegB;
    reg EX_MEM_Cond;
    reg [31: 0] EX_MEM_NPC;

    always @(posedge clk) begin
        if(!resetn) begin
            EX_MEM_IR <= 0;
            EX_MEM_ALU_Output <= 0;
            EX_MEM_RegB <= 0;
            EX_MEM_Cond <= 0;
            EX_MEM_NPC <= 0;
        end
        else if(bMemoryStage) begin
            EX_MEM_IR <= ExecuteOutIR;
            EX_MEM_ALU_Output <= ExecuteOut_ALU_Output;
            EX_MEM_RegB <= ExecuteOutRegB;
            EX_MEM_Cond <= ExecuteOutCond;
            EX_MEM_NPC <= ExecuteOutNPC;
        end
    end

    wire MemoryAccessOutCond;
    wire [31: 0] MemoryAccessOutLMD;
    wire [31: 0] MemoryAccessOutALU_Output;
    wire [31: 0] MemoryAccessOutIR;

    MemoryAccess memoryAccess(
        .clk (clk),
        .rst (resetn),

        .EN (bMemoryStage),

        .IR (EX_MEM_IR),
        .ALU_Output (EX_MEM_ALU_Output),
        .RegB (EX_MEM_RegB),
        .cond (EX_MEM_Cond),
        .nextPC (EX_MEM_NPC),

        .condOut        (MemoryAccessOutCond),
        .LMD            (MemoryAccessOutLMD),
        .ALU_Output_Out (MemoryAccessOutALU_Output),
        .IROut          (MemoryAccessOutIR),

        .predictPC (MemoryAccessOutNPC)
    );

    reg MEM_WB_Cond;
    reg [31: 0] MEN_WB_LMD;
    reg [31: 0] MEM_WB_ALU_Output;
    reg [31: 0] MEM_WB_IR;

    always @(posedge clk) begin
        if(!resetn) begin
            MEM_WB_Cond <= 0;
            MEN_WB_LMD <= 0;
            MEM_WB_ALU_Output <= 0;
            MEM_WB_IR <= 0;
        end
        else if(bWriteBackStage) begin
            MEM_WB_Cond <= MemoryAccessOutCond;
            MEN_WB_LMD <= MemoryAccessOutLMD;
            MEM_WB_ALU_Output <= MemoryAccessOutALU_Output;
            MEM_WB_IR <= MemoryAccessOutIR;
        end
    end

    WriteBack writeBack(
        .clk (clk),
        .rst (resetn),

        .EN (bWriteBackStage),

        .cond     (MEM_WB_Cond),
        .LMD        (MEN_WB_LMD),
        .ALU_Output (MEM_WB_ALU_Output),
        .IR         (MEM_WB_IR),

        .valWriteEN (valWriteEN),
        .valWrite   (valWrite)
    );

    assign debug_wb_rf_wen = valWriteEN;
    assign debug_wb_rf_wdata = valWrite;


endmodule
