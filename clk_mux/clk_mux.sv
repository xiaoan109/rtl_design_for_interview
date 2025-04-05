module clk_mux #(
  parameter NUM_INPUTS = 2,
  parameter NUM_SYNC_STAGES = 2,
  parameter CLOCK_DURING_RESET = 1,
  localparam SEL_WIDTH = $clog2(NUM_INPUTS)
) (
  input wire [NUM_INPUTS-1:0] clks_i,
  input wire async_rstn_i,
  input wire [SEL_WIDTH-1:0] async_sel_i,
  output wire clk_o
);

  reg [NUM_INPUTS-1:0] s_sel_onehot;
  reg [1:0] r_glitch_filter[NUM_INPUTS-1:0];
  reg [NUM_INPUTS-1:0] s_gate_enable_unfiltered_async;
  wire [NUM_INPUTS-1:0] s_glitch_filter_output_async;
  wire [NUM_INPUTS-1:0] s_gate_enable_sync;
  wire [NUM_INPUTS-1:0] s_gate_enable;
  reg [NUM_INPUTS-1:0] r_clock_has_been_disabled;
  wire [NUM_INPUTS-1:0] s_gated_clock;
  wire s_output_clock;

  wire [NUM_INPUTS-1:0] s_reset_synced;
  reg [NUM_INPUTS-1:0] r_async_reset_bypass_active;

  // Onehot decoder
  always @(*) begin
    s_sel_onehot = 0;
    s_sel_onehot[async_sel_i] = 1'b1;
  end

  // Input stages
  genvar i;
  integer j;
  generate
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin: gen_input_stages
      // Sync reset into each clock domain
      rstgen #(
        .NumRegs(2)
      ) i_rst_gen (
        .clk_i(clks_i[i]),
        .rst_ni(async_rstn_i),
        .rst_no(s_reset_synced[i]),
        .init_no()
      );

      // Gate onehot signal with other clocks' output gate enable
      always @(*) begin
        s_gate_enable_unfiltered_async[i] = 1'b1;
        for(j = 0; j < NUM_INPUTS; j = j + 1) begin
          if(i==j) begin
            s_gate_enable_unfiltered_async[i] = s_gate_enable_unfiltered_async[i] & s_sel_onehot[j];
          end else begin
            s_gate_enable_unfiltered_async[i] = s_gate_enable_unfiltered_async[i] & r_clock_has_been_disabled[j];
          end
        end
      end

      // Filter high pulse glitches
      always @(posedge clks_i[i] or negedge s_reset_synced[i]) begin
        if(~s_reset_synced[i]) begin
          r_glitch_filter[i] <= 2'b0;
        end else begin
          r_glitch_filter[i] <= {r_glitch_filter[i][0], s_gate_enable_unfiltered_async[i]};
        end
      end

      assign s_glitch_filter_output_async[i] = r_glitch_filter[i][1] & r_glitch_filter[i][0] & s_gate_enable_unfiltered_async[i];


      // Sync to current clock
      sync #(
        .STAGES(NUM_SYNC_STAGES)
      ) i_sync_en (
        .clk_i(clks_i[i]),
        .rst_ni(s_reset_synced[i]),
        .serial_i(s_glitch_filter_output_async[i]),
        .serial_o(s_gate_enable_sync[i])
      );


      if(CLOCK_DURING_RESET) begin
        always @(posedge clks_i[i] or negedge s_reset_synced[i]) begin
          if(~s_reset_synced[i]) begin
            r_async_reset_bypass_active[i] <= 1'b1;
          end else begin
            r_async_reset_bypass_active[i] <= 1'b0;
          end
        end

        assign s_gate_enable[i] = r_async_reset_bypass_active[i] ? s_gate_enable_unfiltered_async[i] : s_gate_enable_sync[i];

      end else begin
        assign s_gate_enable[i] = s_gate_enable_sync[i];
      end

      clk_gating i_clk_gate (
        .clk_i(clks_i[i]),
        .en_i(s_gate_enable[i]),
        .clk_o(s_gated_clock[i])
      );


      always @(posedge clks_i[i] or negedge s_reset_synced[i]) begin
        if(~s_reset_synced[i]) begin
          r_clock_has_been_disabled[i] <= 1'b1;
        end else begin
          r_clock_has_been_disabled[i] <= ~s_gate_enable[i];
        end
      end
    end
  endgenerate

  clk_or_tree #(
    .NUM_INPUTS(NUM_INPUTS)
  ) i_clk_or_tree(
    .clks_i(s_gated_clock),
    .clk_o(s_output_clock)
  );

  assign clk_o = s_output_clock;

endmodule



// Helper Module to generate an N-input clock OR-gate from a tree of tc_clk_or2 cells.
module clk_or_tree #(
  parameter NUM_INPUTS
) (
  input wire [NUM_INPUTS-1:0] clks_i,
  output wire clk_o
);

  generate 
    if (NUM_INPUTS < 1) begin : gen_error
      // $error("Cannot parametrize clk_or with less then 1 input but was %0d", NUM_INPUTS);
    end else if (NUM_INPUTS == 1) begin : gen_leaf
      assign clk_o          = clks_i[0];
    end else if (NUM_INPUTS == 2) begin : gen_leaf
      assign clk_o = clks_i[0] || clks_i[1];
    end else begin  : gen_recursive
      wire branch_a, branch_b;
      clk_or_tree #(NUM_INPUTS/2) i_or_branch_a (
        .clks_i(clks_i[0+:NUM_INPUTS/2]),
        .clk_o(branch_a)
      );

      clk_or_tree #(NUM_INPUTS/2 + NUM_INPUTS%2) i_or_branch_b (
        .clks_i(clks_i[NUM_INPUTS-1:NUM_INPUTS/2]),
        .clk_o(branch_b)
      );

      assign clk_o = branch_a || branch_b;
    end
  endgenerate

endmodule
