module lru_selector (
    input clk, // 时钟信号
    input rst,

    input [11: 5] last_index,
    input [3: 0] hit,
    input [2: 0] state,

    output [3: 0] sel_way

);

    reg [11: 5] reg_last_index;

    reg [3: 0] lru_sel_way [127:0];

    always @(posedge clk) begin
        if(!rst) begin
            reg_last_index <= 7'b000_0000;
        end
        else begin
            reg_last_index <= last_index;
        end
    end

    genvar i;
    generate
        for (i = 0 ; i < 128 ; i = i + 1) begin
            lru_matrix u_lru_matrix(
                .clk (clk),
                .rst (rst),
                .wen (last_index == i),
                .hit (hit),
                .state (state),

                .sel_way (lru_sel_way[i])
            );
        end
    endgenerate

    assign sel_way = lru_sel_way[last_index];

endmodule