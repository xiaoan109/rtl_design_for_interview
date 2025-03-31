module cdc_2phase#(
    parameter DW = 8
) (
    input wire src_clk_i,
    input wire src_rst_ni,
    input wire [DW-1:0] src_data_i,
    input wire src_valid_i,
    output wire src_ready_o,

    input wire dst_clk_i,
    input wire dst_rst_ni,
    output wire [DW-1:0] dst_data_o,
    output wire dst_valid_o,
    input wire dst_ready_i
);

    // async signals
    wire async_req_w;
    wire async_ack_w;
    wire [DW-1:0] async_data_w;

    // src clock domain
    reg req_src_r;
    reg ack_src_r;
    reg ack_src_r1;
    reg [DW-1:0] data_src_r;
    always @(posedge src_clk_i or negedge src_rst_ni) begin
        if(~src_rst_ni) begin
            req_src_r <= 1'b0;
            data_src_r <= 0;
        end else if(src_valid_i && src_ready_o) begin
            req_src_r <= ~req_src_r;
            data_src_r <= src_data_i;
        end
    end

    // back to back (2-stage)
    always @(posedge src_clk_i or negedge src_rst_ni) begin
        if(~src_rst_ni) begin
            ack_src_r <= 1'b0;
            ack_src_r1 <= 1'b0;
        end else begin
            ack_src_r <= async_ack_w;
            ack_src_r1 <= ack_src_r;
        end
    end

    // assignments
    assign src_ready_o = (req_src_r == ack_src_r1);
    assign async_req_w = req_src_r;
    assign async_data_w = data_src_r;


    // dst clock domain
    reg req_dst_r;
    reg req_dst_r1;
    reg req_dst_r2;
    reg ack_dst_r;
    reg [DW-1:0] data_dst_r;

    always @(posedge dst_clk_i or negedge dst_rst_ni) begin
        if(~dst_rst_ni) begin
            ack_dst_r <= 1'b0;
        end else if(dst_valid_o & dst_ready_i) begin
            ack_dst_r <= ~ack_dst_r;
        end
    end

    always @(posedge dst_clk_i or negedge dst_rst_ni) begin
        if(~dst_rst_ni) begin
            data_dst_r <= 0;
        end else if(req_dst_r1 != req_dst_r2 && !dst_valid_o) begin
            data_dst_r <= async_data_w;
        end
    end

    // back to back (3-stage)
    always @(posedge dst_clk_i or negedge dst_rst_ni) begin
        if(~dst_rst_ni) begin
            req_dst_r <= 1'b0;
            req_dst_r1 <= 1'b0;
            req_dst_r2 <= 1'b0;
        end else begin
            req_dst_r <= async_req_w;
            req_dst_r1 <= req_dst_r;
            req_dst_r2 <= req_dst_r1;
        end
    end

    // assigments
    assign dst_valid_o = (ack_dst_r != req_dst_r2);
    assign dst_data_o = data_dst_r;
    assign async_ack_w = ack_dst_r;

endmodule