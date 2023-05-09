`include "parameter.vh";

module controller(
    input clk, // 时钟信号
    input rst,

    input arready,
    input rlast,
    input rvalid,

    input cpu_req,
    input [3: 0] hit_array,
    input [3 :0] rid,
    input [11: 5] last_index,

    output reg [2:0] state,
    output [3: 0] arid,

    output reg [3: 0] sel_way,
    output reg [31: 0] wdata_wen,

    output reg addr_ok,
    // output reg data_ok,
    output data_ok,
    output reg arvalid_ok,
    output reg rready,

    output reg first_run

);
    reg first_miss;
    reg first_refill;
    reg [31: 0] reg_wdata_wen;
    wire [3: 0] lru_sel_way;
    wire hit;
    assign hit = hit_array != 4'h0;

    lru_selector u_lru_selector(
        .clk (clk),
        .rst (rst),
        .last_index (last_index),
        .hit (hit_array),
        .state (state),
        .sel_way (lru_sel_way)
    );
    
    assign arid = `AXI_ID;

    /* DFA */
    always @(posedge clk) begin
        if (!rst) begin
            state <= `RESETN;
            first_run <= 1'b0;
            first_miss <= 1'b0;
        end
        else begin
            /*TODO：根据设计的自动机的状态转移规则进行实现 */
            if(state == `RESETN) begin
                state <= `IDLE;
            end
            if(state == `IDLE && cpu_req) begin
                state <= `RUN;
                first_run <= 1'b1;
            end
            else if(state == `RUN && first_run) begin
                first_run <= 1'b0;
            end
            else if(state == `RUN && !first_run && !hit) begin
                state <= `SEL_WAY;
            end
            else if(state == `SEL_WAY) begin
                state <= `MISS;
                first_miss <= 1'b1;
            end
            else if(state == `SEL_WAY && first_miss) begin
                first_miss <= 1'b0;
            end
            else if(state == `MISS) begin
                if(arready == 1'b1) begin
                    state <= `REFILL;
                end
                else begin
                    state <= `MISS;
                end
            end
            else if(state == `REFILL) begin
                if(rlast) begin
                    state <= `FINISH;
                end
                else begin
                    state <= `REFILL;
                end
            end
            else if(state == `FINISH) begin
                state <= `RUN;
            end
            else if(state == `RUN && !cpu_req) begin
                state <= `IDLE;
            end
        end
    end

    /* 某功能模块 */
    always @(posedge clk) begin

        if (!rst) begin
        /*TODO：初始化相关寄存器 */
        end
        else begin
            if (state == `IDLE) begin
            /*TODO：该模块在 idle 状态下的行为 */
            end
            else if (state == `RUN) begin
            /*TODO：该模块在 run 状态下的行为 */
            end
            else if(state == `SEL_WAY) begin
                
            end
            else if(state == `MISS) begin
                
            end
            // ...
        end        
    end

    always @(posedge clk) begin
        if (!rst) begin
            arvalid_ok <= 1'b0;
        end
        else begin
            if(state == `MISS) begin
                arvalid_ok <= 1'b1;
            end
            else begin
                arvalid_ok <= 1'b0;
            end
        end
    end

    // 选择某一路 Cache
    always @(posedge clk) begin
        if (!rst) begin
            sel_way <= 4'b0000;
        end
        else begin
            if(state == `MISS || state == `REFILL) begin
                // sel_way <= 4'b0001;
                sel_way <= lru_sel_way;
            end
            else begin
                sel_way <= 4'b0000;
            end
        end
    end
    
    always @(posedge clk) begin
        if (!rst) begin
            rready <= 1'b0;
        end
        else begin
            if (state == `REFILL && rvalid) begin
                rready <= 1'b1;
            end
            else begin
                rready <= 1'b0;
            end
        end        
    end

    always @(posedge clk) begin
        if (!rst) begin
            reg_wdata_wen <= 32'h0000_0000;
            wdata_wen <= 32'h0000_0000;
        end
        else begin
            if(state == `REFILL && first_refill && rvalid) begin
                reg_wdata_wen <= 32'hf000_0000;
                wdata_wen <= 32'hf000_0000;
            end
            else if(state == `REFILL && rvalid) begin
                wdata_wen <= {4'h0, reg_wdata_wen[31: 4]};
                reg_wdata_wen <= {4'h0, reg_wdata_wen[31: 4]};
            end
            else begin
                wdata_wen <= 32'h0000_0000;
            end
        end  
    end

    always @(posedge clk) begin
        if (!rst) begin
            first_refill <= 1'b0;
        end
        else begin
            if (state == `REFILL && arready == 1'b1) begin
                first_refill <= 1'b1;
            end
            else if(state == `REFILL && first_refill && rvalid) begin
                first_refill <= 1'b0;
            end
        end  
    end
    
    // always @(posedge clk) begin
    //     if(!rst) begin
    //         addr_ok <= 1'b0;
    //     end
    //     else begin
    //         if(cpu_req && state == `IDLE) begin
    //             addr_ok <= 1'b1;
    //         end
    //         else if(state == `RUN && ((first_run) || (!first_run && hit))) begin // 转换到 RUN 的第一个周期也是 true
    //             addr_ok <= 1'b1;
    //         end
    //         else if(state == `FINISH && hit) begin
    //             addr_ok <= 1'b1;
    //         end
    //         else begin
    //             addr_ok <= 1'b0;
    //         end
    //     end
    // end

    assign addr_ok = 
                    !rst ? 1'b0 :
                    cpu_req && state == `IDLE ? 1'b1 :
                    state == `RUN && (first_run || hit) ? 1'b1 :
                    1'b0;

    // always @(posedge clk) begin
    //     if(!rst) begin
    //         data_ok <= 1'b0;
    //     end
    //     else begin
    //         if((state == `FINISH || state == `RUN) && hit) begin
    //             data_ok <= 1'b1;
    //         end
    //         else begin
    //             data_ok <= 1'b0;
    //         end
    //     end
    // end

    assign data_ok = 
                !rst ? 1'b0 : 
                state == `RUN && !first_run && hit ? 1'b1 :
                1'b0;

endmodule