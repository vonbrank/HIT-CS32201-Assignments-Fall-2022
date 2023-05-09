`include "../parameter.vh";

module lru_matrix (
    input clk, // 时钟信号
    input rst,
    input wen,
    input [3: 0] hit,
    input [2: 0] state,

    output [3: 0] sel_way

);

    reg [3: 0] reg_lru_matrix [3: 0];
    wire [3: 0] row_sum [3: 0];
    wire [3: 0] less_than_others;
    reg [2: 0] i;
    reg [2: 0] j;
    wire [2: 0] hit_num;
    assign hit_num = 
                hit[0] ? 3'd0 :
                hit[1] ? 3'd1 :
                hit[2] ? 3'd2 :
                         3'd3;
    assign row_sum[0] = reg_lru_matrix[0][0] + reg_lru_matrix[0][1] + reg_lru_matrix[0][2] + reg_lru_matrix[0][3];
    assign row_sum[1] = reg_lru_matrix[1][0] + reg_lru_matrix[1][1] + reg_lru_matrix[1][2] + reg_lru_matrix[1][3];
    assign row_sum[2] = reg_lru_matrix[2][0] + reg_lru_matrix[2][1] + reg_lru_matrix[2][2] + reg_lru_matrix[2][3];
    assign row_sum[3] = reg_lru_matrix[3][0] + reg_lru_matrix[3][1] + reg_lru_matrix[3][2] + reg_lru_matrix[3][3];
    assign less_than_others[0] = row_sum[0] <= row_sum[1] && row_sum[0] <= row_sum[2] && row_sum[0] <= row_sum[3];
    assign less_than_others[1] = row_sum[1] <= row_sum[0] && row_sum[1] <= row_sum[2] && row_sum[1] <= row_sum[3];
    assign less_than_others[2] = row_sum[2] <= row_sum[0] && row_sum[2] <= row_sum[1] && row_sum[2] <= row_sum[3];
    assign less_than_others[3] = row_sum[3] <= row_sum[0] && row_sum[3] <= row_sum[1] && row_sum[3] <= row_sum[2];
    assign sel_way = 
                less_than_others[0] ? 4'b0001 :
                less_than_others[1] ? 4'b0010 :
                less_than_others[2] ? 4'b0100 :
                                      4'b1000;

    always @(posedge clk) begin
        if(!rst) begin
            for(i = 0 ; i < 4 ; i = i + 1) begin
                reg_lru_matrix[i] <= 4'b0000;
            end
        end
        else begin
            if(wen && state == `RUN && hit != 4'b0000 ) begin
                if(hit_num == 3'd0) begin
                    reg_lru_matrix[0][1] <= 1'b1;
                    reg_lru_matrix[0][2] <= 1'b1;
                    reg_lru_matrix[0][3] <= 1'b1;

                    reg_lru_matrix[0][0] <= 1'b0;
                    reg_lru_matrix[1][0] <= 1'b0;
                    reg_lru_matrix[2][0] <= 1'b0;
                    reg_lru_matrix[3][0] <= 1'b0;
                end
                if(hit_num == 3'd1) begin
                    reg_lru_matrix[1][0] <= 1'b1;
                    reg_lru_matrix[1][2] <= 1'b1;
                    reg_lru_matrix[1][3] <= 1'b1;

                    reg_lru_matrix[0][1] <= 1'b0;
                    reg_lru_matrix[1][1] <= 1'b0;
                    reg_lru_matrix[2][1] <= 1'b0;
                    reg_lru_matrix[3][1] <= 1'b0;
                end
                if(hit_num == 3'd2) begin
                    reg_lru_matrix[2][0] <= 1'b1;
                    reg_lru_matrix[2][1] <= 1'b1;
                    reg_lru_matrix[2][3] <= 1'b1;

                    reg_lru_matrix[0][2] <= 1'b0;
                    reg_lru_matrix[1][2] <= 1'b0;
                    reg_lru_matrix[2][2] <= 1'b0;
                    reg_lru_matrix[3][2] <= 1'b0;
                end
                if(hit_num == 3'd3) begin
                    reg_lru_matrix[3][0] <= 1'b1;
                    reg_lru_matrix[3][1] <= 1'b1;
                    reg_lru_matrix[3][2] <= 1'b1;

                    reg_lru_matrix[0][3] <= 1'b0;
                    reg_lru_matrix[1][3] <= 1'b0;
                    reg_lru_matrix[2][3] <= 1'b0;
                    reg_lru_matrix[3][3] <= 1'b0;
                end
                // for(i = 0 ; i < 4 ; i = i + 1) begin
                //     if(i != hit_num) begin
                //         reg_lru_matrix[hit_num] <= 1'b1;
                //     end
                // end
                // for(j = 0 ; j < 4 ; j = j + 1) begin
                //     reg_lru_matrix[j][hit_num] <= 1'b0;
                // end
            end
        end
    end



endmodule