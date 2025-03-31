module cdc_4phase #(
    parameter DW = 8,
    parameter DECOUPLED = 1
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

    // ---------------------------------------------------------
    // src clock domain
    // ---------------------------------------------------------
    reg req_src_r;
    reg [DW-1:0] data_src_r;
    reg ack_src_r;
    reg ack_src_r1;

    // state machine
    parameter SRC_IDLE = 0;
    parameter WAIT_ACK_ASSERT = 1;
    parameter WAIT_ACK_DEASSERT = 2;

    reg [1:0] state_src_r;
    reg [1:0] next_src_r;

    // sync async ack, 2-stage back to back
    always @(posedge src_clk_i or negedge src_rst_ni) begin
        if(~src_rst_ni) begin
            ack_src_r <= 1'b0;
            ack_src_r1 <= 1'b0;
        end else begin
            ack_src_r <= async_ack_w;
            ack_src_r1 <= ack_src_r;
        end
    end

    // FSM
    always @(*) begin
        next_src_r = state_src_r;
        case(state_src_r)
            SRC_IDLE: if(src_valid_i) next_src_r = WAIT_ACK_ASSERT;
            WAIT_ACK_ASSERT: if(ack_src_r1) next_src_r = WAIT_ACK_DEASSERT;
            WAIT_ACK_DEASSERT: if(~ack_src_r1) next_src_r = SRC_IDLE;
            default: next_src_r = SRC_IDLE;
        endcase
    end

    always @(posedge src_clk_i or negedge src_rst_ni) begin
        if(~src_rst_ni) begin
            state_src_r <= SRC_IDLE;
        end else begin
            state_src_r <= next_src_r;
        end
    end

    // req and data
    always @(posedge src_clk_i or negedge src_rst_ni) begin
        if(~src_rst_ni) begin
            req_src_r <= 1'b0;
        end else begin
            case(state_src_r)
                SRC_IDLE: req_src_r <= src_valid_i ? 1'b1 : 1'b0;
                WAIT_ACK_ASSERT: req_src_r <= ack_src_r1 ? 1'b0 : 1'b1;
                default: req_src_r <= 1'b0;
            endcase
        end
    end

    always @(posedge src_clk_i or negedge src_rst_ni) begin
        if(~src_rst_ni) begin
            data_src_r <= 0;
        end else if(state_src_r == SRC_IDLE && src_valid_i) begin
            data_src_r <= src_data_i;
        end
    end

    // assignments
    assign async_req_w = req_src_r;
    assign async_data_w = data_src_r;
    assign src_ready_o = DECOUPLED ? (state_src_r == SRC_IDLE ) : (state_src_r == WAIT_ACK_DEASSERT && ~ack_src_r1);


    // ---------------------------------------------------------
    // dst clock domain
    // ---------------------------------------------------------
    reg ack_dst_r;
    reg req_dst_r;
    reg req_dst_r1;
    wire data_valid;
    wire output_ready;

    // state machine
    parameter DST_IDLE = 0;
    parameter WAIT_DOWNSTREAM_ACK = 1;
    parameter WAIT_REQ_DEASSERT = 2;

    reg [1:0] state_dst_r;
    reg [1:0] next_dst_r;

    // sync req ack, 2-stage back to back
    always @(posedge dst_clk_i or negedge dst_rst_ni) begin
        if(~src_rst_ni) begin
            req_dst_r <= 1'b0;
            req_dst_r1 <= 1'b0;
        end else begin
            req_dst_r <= async_req_w;
            req_dst_r1 <= req_dst_r;
        end
    end

    // FSM
    always @(*) begin
        next_dst_r = state_dst_r;
        case(state_dst_r)
            DST_IDLE: if(req_dst_r1) next_dst_r = output_ready ? WAIT_REQ_DEASSERT : WAIT_DOWNSTREAM_ACK;
            WAIT_DOWNSTREAM_ACK: if(output_ready) next_dst_r = WAIT_REQ_DEASSERT;
            WAIT_REQ_DEASSERT: if(~req_dst_r1) next_dst_r = DST_IDLE;
            default: next_dst_r = DST_IDLE;
        endcase
    end

    always @(posedge dst_clk_i or negedge dst_rst_ni) begin
        if(~dst_rst_ni) begin
            state_dst_r <= DST_IDLE;
        end else begin
            state_dst_r <= next_dst_r;
        end
    end

    // ack
    always @(posedge dst_clk_i or negedge dst_rst_ni) begin
        if(~dst_rst_ni) begin
            ack_dst_r <= 1'b0;
        end else begin
            case(state_dst_r)
                WAIT_DOWNSTREAM_ACK: if(output_ready) ack_dst_r <= 1'b1;
                WAIT_REQ_DEASSERT: ack_dst_r <= req_dst_r1 ? 1'b1 : 1'b0;
                default: ack_dst_r <= 1'b0;
            endcase
        end
    end

    // assignments

    generate
        if (DECOUPLED) begin : gen_decoupled
            // Decouple the output from the asynchronous data bus without introducing
            // additional latency by inserting a spill register
            spill_register #(
                .T(reg [DW-1:0]),
                .Bypass(1'b0)
            ) i_spill_register (
                .clk_i(dst_clk_i),
                .rst_ni(dst_rst_ni),
                .valid_i(data_valid),
                .ready_o(output_ready),
                .data_i(async_data_w),
                .valid_o(dst_valid_o),
                .ready_i(dst_ready_i),
                .data_o(dst_data_o)
            );
        end else begin : gen_not_decoupled
            assign dst_valid_o      = data_valid;
            assign output_ready     = dst_ready_i;
            assign dst_data_o       = async_data_w;
        end
    endgenerate

    assign async_ack_w = ack_dst_r;
    assign data_valid = (state_dst_r == DST_IDLE && req_dst_r1) || (state_dst_r == WAIT_DOWNSTREAM_ACK);

endmodule