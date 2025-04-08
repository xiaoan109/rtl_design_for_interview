module rr_arbiter #(
    parameter NUM_REQ = 4
) (
    input wire clk_i,
    input wire rst_ni,
    input wire [NUM_REQ-1:0] req_i,
    output wire [NUM_REQ-1:0] gnt_o
);

reg [NUM_REQ-1:0] base_r;
wire [2*NUM_REQ-1:0] double_req_r;
wire [2*NUM_REQ-1:0] double_gnt_r;

always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
        base_r <= {{NUM_REQ-1{1'b0}}, 1'b1};
    end else begin
        if(|req_i) begin
            base_r <= {gnt_o[NUM_REQ-2:0], gnt_o[NUM_REQ-1]};
        end
    end
end

assign double_req_r = {req_i, req_i};
assign double_gnt_r = double_req_r & ~(double_req_r - base_r);

assign gnt_o = double_gnt_r[NUM_REQ-1:0] | double_gnt_r[2*NUM_REQ-1:NUM_REQ];


endmodule
