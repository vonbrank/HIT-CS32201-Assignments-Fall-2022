`include "parameter.vh";
module cache (
    input clk , // clock, 100MHz
    input rst , // active low
    // Sram-Like 接口信号定义:
    input cpu_req , //由 CPU 发送至 Cache
    input [31:0] cpu_addr , //由 CPU 发送至 Cache
    output [31:0] cache_rdata , //由 Cache 返回给 CPU
    output cache_addr_ok, //由 Cache 返回给 CPU
    output cache_data_ok, //由 Cache 返回给 CPU
    // AXI 接口信号定义:
    output [3 :0] arid , //Cache 向主存发起读请求时使用的 AXI 信道的 id 号
    output [31:0] araddr , //Cache 向主存发起读请求时所使用的地址
    output arvalid, //Cache 向主存发起读请求的请求信号
    input arready, //读请求能否被接收的握手信号
    input [3 :0] rid , //主存向 Cache 返回数据时使用的 AXI 信道的 id 号
    input [31:0] rdata , //主存向 Cache 返回的数据
    input rlast , //是否是主存向 Cache 返回的最后一个数据
    input rvalid , //主存向 Cache 返回数据时的数据有效信号
    output rready //标识当前的 Cache 已经准备好可以接收主存返回的数据
);

    wire [2: 0] controller_state;
    wire [3: 0] sel_way;
    wire [31: 0] wdata_wen;

    wire [31: 12] last_tag;
    wire [11: 5] last_index;
    wire [4: 0] last_offset;

    wire [3: 0] hit;
    wire [31: 0] rdata_way [3: 0];
    wire first_run;
    wire [31: 0] ll_address;

    reg [6: 0] tagv_reset_counter;

    initial begin
        tagv_reset_counter = 7'b0000000;
    end

    always @(posedge clk) begin
        tagv_reset_counter = tagv_reset_counter + 1;
    end

    request_buffer u_request_buffer(
        .clk (clk),
        .wen (1'b1),
        .rst (rst),

        .cpu_req (cpu_req),
        .cpu_addr (cpu_addr),
        .controller_state (controller_state),

        .cache_addr_ok (cache_addr_ok),
        .hit (hit != 4'h0),
        .first_run (first_run),

        .last_tag (last_tag),
        .last_index (last_index),
        .last_offset (last_offset),
        .ll_address (ll_address)
    );

    assign araddr = {ll_address[31: 5], 5'b00000};

    controller u_controller(
        .clk (clk),
        .rst (rst),

        .arready (arready),
        .rlast (rlast),
        .rvalid (rvalid),

        .cpu_req (cpu_req),
        .hit_array (hit),
        .rid (rid),
        .last_index (last_index),

        .state (controller_state),
        .arid (arid),

        .sel_way (sel_way),
        .wdata_wen (wdata_wen),

        .addr_ok (cache_addr_ok),
        .data_ok (cache_data_ok),
        .arvalid_ok (arvalid),
        .rready (rready),

        .first_run (first_run)
    );

    genvar i;
    generate
        for (i = 0 ; i < 4 ; i = i + 1) begin
            icache_tagv u_icache_tagv(
                .clk (clk),
                .wen (controller_state == `RESETN ? 1'b1 : ((controller_state == `REFILL && rready) ? sel_way[i] : 0'b0)),
                .valid_wdata (controller_state != `RESETN),

                .index ( controller_state == `RESETN ? tagv_reset_counter : last_index ),
                .tag (controller_state == `RESETN ? 20'h00000 : last_tag),
                
                .hit (hit[i])
            );
        end
    endgenerate

    generate
        for (i = 0 ; i < 4 ; i = i + 1) begin
            icache_data u_icache_data(
                .clk (clk),
                .wen (sel_way[i] ? wdata_wen : 32'h0000_0000),

                .index (last_index),
                .offset (last_offset),
                .wdata ({8{rdata}}),
                .rdata (rdata_way[i])
            );
        end
    endgenerate

    assign cache_rdata = 
                    hit[0] ? rdata_way[0] :
                    hit[1] ? rdata_way[1] :
                    hit[2] ? rdata_way[2] :
                    hit[3] ? rdata_way[3] :
                    32'h0000_0000;
                    

endmodule