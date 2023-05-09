//////////////////////////////////////////////////////////////////////////////////
//  @Copyright HIT team
//  CPU Automated testing environment
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

`define TRACE_FILE_PATH "E:/Files/Source/Assignment-02-CPU-Design-Sequential/data/cpu_trace"
`define TEST_COUNT 10

module cpu_top(
    (*mark_debug = "true"*) input         clk     ,
    (*mark_debug = "true"*) input         reset   ,
    (*mark_debug = "true"*) output [15 :0] leds
);

    // Initialize trace file registers
    reg [71:0] trace_data [`TEST_COUNT - 1 :0];

    initial begin
        $readmemh(`TRACE_FILE_PATH , trace_data);
    end

    // Instantiate the cpu
    (*mark_debug = "true"*) wire [31:0] debug_wb_pc;
    (*mark_debug = "true"*) wire        debug_wb_rf_wen;
    (*mark_debug = "true"*) wire [4 :0] debug_wb_rf_addr;
    (*mark_debug = "true"*) wire [31:0] debug_wb_rf_wdata;

    CPU U_cpu(
        .clk               (clk               ),
        .resetn            (reset             ),
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),
        .debug_wb_rf_addr  (debug_wb_rf_addr  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );

    // Compare the cpu data to the reference data
    (*mark_debug = "true"*) reg         test_err;
    (*mark_debug = "true"*) reg         test_pass;
    (*mark_debug = "true"*) reg [31:0] test_counter;
    (*mark_debug = "true"*) reg [15 :0] leds_reg;

    (*mark_debug = "true"*) wire [31:0] ref_wb_pc       = trace_data[test_counter][71:40];
    (*mark_debug = "true"*) wire [4 :0] ref_wb_rf_addr  = trace_data[test_counter][36:32];
    (*mark_debug = "true"*) wire [31:0] ref_wb_rf_wdata = trace_data[test_counter][31: 0];
    
    assign leds = leds_reg;

    always @ (posedge clk) begin
        if (!reset) begin
            leds_reg     <= 16'hffff;
            test_err     <= 1'b0;
            test_pass    <= 1'b0;
            test_counter <= 0;
        end
        else if (debug_wb_pc == 32'h00000040 && !test_err) begin
                $display("    ----PASS!!!");
                $display("Test end!");
                $display("==============================================================");
                test_pass <= 1'b1;
                leds_reg  <= 16'h0000;
                #5;
                $finish;
        end
        else if (debug_wb_rf_wen && |debug_wb_rf_addr && !test_pass) begin
            if (debug_wb_pc != ref_wb_pc || debug_wb_rf_addr != ref_wb_rf_addr || debug_wb_rf_wdata != ref_wb_rf_wdata) begin
            $display("--------------------------------------------------------------");
                $display("Error!!!");
                $display("    test_counter : %2d", test_counter);
                $display("    Reference : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", ref_wb_pc, ref_wb_rf_addr, ref_wb_rf_wdata);
                $display("    Error     : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", debug_wb_pc, debug_wb_rf_addr, debug_wb_rf_wdata);
                $display("--------------------------------------------------------------");
                $display("==============================================================");
                test_err     <= 1'b1;
                #5;
                $finish;
            end
            else begin
                $display("--------------------------------------------------------------");
                $display("Pass test_counter %2d !!!", test_counter);
                $display("    Reference : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", ref_wb_pc, ref_wb_rf_addr, ref_wb_rf_wdata);
                $display("    Value     : PC = 0x%8h, write back reg number = %2d, write back data = 0x%8h", debug_wb_pc, debug_wb_rf_addr, debug_wb_rf_wdata);
                $display("--------------------------------------------------------------");
                $display("==============================================================");
                test_counter <= test_counter + 1;
            end
        end
    end

endmodule
