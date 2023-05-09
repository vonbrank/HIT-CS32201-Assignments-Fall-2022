`include "parameter.vh";

module request_buffer(
    input clk, // 时钟信号
    input wen, // 写使能
    input rst,

    input cpu_req,
    input [31: 0] cpu_addr,
    input [2: 0] controller_state,

    input cache_addr_ok,
    input hit,
    input first_run,

    output [31: 12] last_tag,
    output [11: 5] last_index,
    output [4: 0] last_offset,
    output reg [31: 0] ll_address
);

    reg [31: 12] reg_last_tag;
    reg [11: 5] reg_last_index;
    reg [4: 0] reg_last_offset;

    reg [31: 0] tmp_address;

    always @(posedge clk) begin
        if(!rst)
            {reg_last_tag, reg_last_index, reg_last_offset} <= 32'h0000_0000;
        else begin
            if(cpu_req && (controller_state == `IDLE || (controller_state == `RUN && (first_run || hit))))
                // tmp_address <= {reg_last_tag, reg_last_index, reg_last_offset}
                {reg_last_tag, reg_last_index, reg_last_offset} <= cpu_addr;
        end
    end

    always @(posedge clk) begin
        if(!rst)
            ll_address <= 32'h0000_0000;
        else begin
            if(controller_state == `RUN && (first_run || hit))
                ll_address <= {reg_last_tag, reg_last_index, reg_last_offset};
        end
    end

    assign {last_tag, last_index, last_offset} = 
                (controller_state == `FINISH || controller_state == `REFILL) ? ll_address :
                {reg_last_tag, reg_last_index, reg_last_offset};

endmodule