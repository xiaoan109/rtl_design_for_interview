module seq_det_fsm(
    input wire clk_i,
    input wire rst_ni,
    input wire data_i,
    output wire detected_o
);
// non-parameterized seq 5'b10110, overlapping
typedef enum reg [2:0] {S, S1, S10, S101, S1011, S10110} state_e;

state_e state_r;
state_e next_r;
reg detected_r;

always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        state_r <= S;
    end else begin
        state_r <= next_r;
    end
end

always @(*) begin
    next_r = state_r;
    case(state_r)
        S: next_r = data_i ? S1 : S;
        S1: next_r = data_i ? S1 : S10;
        S10: next_r = data_i ? S101 : S;
        S101: next_r = data_i ? S1011 : S10;
        S1011: next_r = data_i ? S1 : S10110;
        S10110: next_r = data_i ? S1 : S;
        default: next_r = S;
    endcase
end

always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        detected_r <= 1'b0;
    end else if(state_r == S1011 && ~data_i) begin
        detected_r <= 1'b1;
    end else begin
        detected_r <= 1'b0;
    end
end

assign detected_o = detected_r;
endmodule

// use onehot fsm to do non-overlapping parameterize
// FIXME: bug module, do not use
module seq_det_fsm_onehot #(
    parameter DETECT_WIDTH = 5,
    parameter [DETECT_WIDTH-1:0] PATTERN = 5'b10110
) (
    input wire clk_i,
    input wire rst_ni,
    input wire data_i,
    output wire detected_o
);

reg [DETECT_WIDTH:0] state_r;
reg [DETECT_WIDTH:0] next_r;
reg detected_r;
integer i;

always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        state_r <= {{DETECT_WIDTH{1'b0}}, 1'b1};
    end else begin
        state_r <= next_r;
    end
end

always @(*) begin
    next_r = state_r;
    // next_r[0] = state_r[DETECT_WIDTH] && data_i != PATTERN[DETECT_WIDTH-1];
    // next_r[1] = state_r[0] && data_i == PATTERN[DETECT_WIDTH-1];
    // next_r[2] = state_r[1] && data_i == PATTERN[DETECT_WIDTH-2];
    // ...
    // next_r[DETECT_WIDTH] = state_r[DETECT_WIDTH-1] && data_i == PATTERN[0];

    next_r[0] = state_r[DETECT_WIDTH] && data_i != PATTERN[DETECT_WIDTH-1];
    for(i = 1; i <= DETECT_WIDTH; i = i + 1) begin
        next_r[i] = state_r[i-1] && data_i == PATTERN[DETECT_WIDTH-i];
    end

    if(~|next_r) begin
        next_r  = {{DETECT_WIDTH{1'b0}}, 1'b1};
    end
end


always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        detected_r <= 1'b0;
    end else if(state_r[DETECT_WIDTH-1] && data_i == PATTERN[0]) begin
        detected_r <= 1'b1;
    end else begin
        detected_r <= 1'b0;
    end
end

assign detected_o = detected_r;

endmodule
