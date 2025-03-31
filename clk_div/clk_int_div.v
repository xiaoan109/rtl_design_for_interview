`default_nettype none

module clk_int_div #(
  // div value width
  parameter int unsigned DIV_VALUE_WIDTH = 4,
  // default div value used right after reset
  parameter int unsigned DEFAULT_DIV_VALUE = 0,
  // enable output clock during reset
  parameter bit          ENABLE_CLOCK_IN_RESET = 1'b0
) (
  input  wire                       clk_i,
  input  wire                       rst_ni,
  // enable output clock
  input  wire                       en_i,
  // bypass the clock in test mode
  input  wire                       test_mode_en_i,
  // divider select value, output clock frequency = f_clk_i/div_i
  input  wire [DIV_VALUE_WIDTH-1:0] div_i,
  // handshake signal
  input  wire                       div_valid_i,
  output wire                       div_ready_o,
  // output clock
  output wire                       clk_o
);

  if ($clog2(DEFAULT_DIV_VALUE+1) > DIV_VALUE_WIDTH) begin : gen_elab_error
    $error("Default divider value %0d is not representable with the configured",
            "div value width of %0d bits.",
           DEFAULT_DIV_VALUE, DIV_VALUE_WIDTH);
  end

  localparam int unsigned DivResetValue = (DEFAULT_DIV_VALUE != 0 ) ? DEFAULT_DIV_VALUE : 1;

  wire [DIV_VALUE_WIDTH-1:0] div_i_normalized;
  reg  [DIV_VALUE_WIDTH-1:0] div_q;
  reg  [DIV_VALUE_WIDTH-1:0] cycle_cntr_q;
  reg                        gate_is_open_q;
  reg                        clk_div_bypass_en_q;
  reg                        use_odd_division_q;
  reg                        gate_en_q;
  reg                        t_ff1_q;
  reg                        t_ff2_q;
  reg                        toggle_ffs_en;
  wire                       even_clk;
  wire                       odd_clk;
  wire                       generated_clk;
  wire                       ungated_output_clk;
  reg                        clk_en;
  reg                        div_ready_q;
  
  typedef enum {IDLE, LOAD_DIV, WAIT_END_PERIOD} clk_gate_state_e;
  clk_gate_state_e clk_gate_state_d, clk_gate_state_q;

  assign div_i_normalized = (div_i != 0) ? div_i : 1;

  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      clk_gate_state_q <= IDLE;
    end else begin
      clk_gate_state_q <= clk_gate_state_d;
    end
  end

  always @(*) begin
    clk_gate_state_d = clk_gate_state_q;
    case(clk_gate_state_q)
      IDLE: begin
        if(div_valid_i && div_i_normalized != div_q) begin
          clk_gate_state_d = LOAD_DIV;
        end
      end
      LOAD_DIV: begin
        if(!gate_is_open_q || clk_div_bypass_en_q) begin
          clk_gate_state_d = WAIT_END_PERIOD;
        end
      end
      WAIT_END_PERIOD: begin
        if(cycle_cntr_q == div_q - 1) begin
          clk_gate_state_d = IDLE;
        end
      end
      default: begin 
        clk_gate_state_d = IDLE;
      end
    endcase
  end


  // div handshake ready
  always @(*) begin
    div_ready_q = 1'b0;
    if(clk_gate_state_q == IDLE && div_valid_i && div_i_normalized == div_q) begin
      div_ready_q = 1'b1;
    end else if(clk_gate_state_q == LOAD_DIV && (!gate_is_open_q || clk_div_bypass_en_q)) begin
      div_ready_q = 1'b1;
    end
  end

  assign div_ready_o = div_ready_q;

  localparam bit UseOddDivisionResetValue = DEFAULT_DIV_VALUE[0];
  localparam bit ClkDivBypassEnResetValue = (DEFAULT_DIV_VALUE < 2) ? 1'b1 : 1'b0;

  // 1. odd or even division
  // 2. bypass the clock if div == 1 or 0
  // 3. update div reg
  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      use_odd_division_q <= UseOddDivisionResetValue;
      clk_div_bypass_en_q <= ClkDivBypassEnResetValue;
      div_q <= DivResetValue;
    end else if(clk_gate_state_q == LOAD_DIV && (!gate_is_open_q || clk_div_bypass_en_q)) begin
      use_odd_division_q <= div_i_normalized[0];
      clk_div_bypass_en_q <= div_i_normalized == 1;
      div_q <= div_i_normalized;
    end
  end
  
  // enable clock when div keeps unchanged 
  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      gate_en_q <= ENABLE_CLOCK_IN_RESET;
    end else if(clk_gate_state_q == IDLE && (!div_valid_i || div_i_normalized == div_q)) begin
      gate_en_q <= 1'b1;
    end else begin
      gate_en_q <= 1'b0;
    end
  end

  // update cycle counter
  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      cycle_cntr_q <= '0;
    end else if(clk_gate_state_q == LOAD_DIV && (!gate_is_open_q || clk_div_bypass_en_q)) begin // clear counter
      cycle_cntr_q <= '0;
    end else begin
      if(!(clk_gate_state_q == IDLE && !div_valid_i  && !en_i  && !gate_is_open_q)) begin // enable counter
        if(clk_div_bypass_en_q || (cycle_cntr_q == div_q - 1)) begin
          cycle_cntr_q <= 'd0;
        end else begin
          cycle_cntr_q <= cycle_cntr_q + 1;
        end
      end
    end
  end

  // TFFs to get even and odd clocks
  // These T-Flip-Flop intentionally use blocking assignments! If we were to use
  // non-blocking assignment like we normally do for flip-flops, we would create
  // a race condition when sampling data from the fast clock domain into
  // flip-flops clocked by t_ff1_q and t_ff2_q. To avoid this, we use blocking assignments
  // which is the recomended method acording to:
  // S. Sutherland and D. Mills,
  // Verilog and System Verilog gotchas: 101 common coding errors and how to
  // avoid them. New York: Springer, 2007. page 64./

  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      t_ff1_q = '0;
    end else if(!clk_div_bypass_en_q && toggle_ffs_en) begin
      if(use_odd_division_q) begin
        t_ff1_q = (cycle_cntr_q == 0) ? ~t_ff1_q : t_ff1_q;
      end else begin
        t_ff1_q = (cycle_cntr_q == 0 || cycle_cntr_q == div_q/2) ? ~t_ff1_q : t_ff1_q;
      end
    end
  end

  always @(posedge clk_i or negedge rst_ni) begin
    if(~rst_ni) begin
      t_ff2_q = '0;
    end else if(!clk_div_bypass_en_q && toggle_ffs_en) begin
      if(use_odd_division_q) begin
        t_ff2_q = (cycle_cntr_q == (div_q+1)/2) ? ~t_ff2_q : t_ff2_q;
      end
    end
  end

  always @(*) begin
    toggle_ffs_en = 1'b1;
    if(clk_gate_state_q == IDLE) begin
      if(!div_valid_i && !en_i && !gate_is_open_q) begin
        toggle_ffs_en = 1'b0;
      end
    end else if(clk_gate_state_q == LOAD_DIV) begin
      if(!gate_is_open_q || clk_div_bypass_en_q) begin
        toggle_ffs_en = 1'b0;
      end
    end else if(clk_gate_state_q == WAIT_END_PERIOD) begin
      toggle_ffs_en = 1'b0;
    end
  end


  assign even_clk = t_ff1_q;

  assign odd_clk = t_ff1_q ^ t_ff2_q;

  assign generated_clk = use_odd_division_q ? odd_clk : even_clk;

  assign ungated_output_clk = (clk_div_bypass_en_q || test_mode_en_i) ? clk_i : generated_clk;

  // clock gate logic

  always @(posedge ungated_output_clk or negedge rst_ni) begin
    if(~rst_ni) begin
      gate_is_open_q <= 1'b0;
    end else begin
      gate_is_open_q <= gate_en_q && en_i;
    end
  end

  always @(*) begin // latch
    if(!ungated_output_clk) clk_en = (gate_en_q && en_i) || test_mode_en_i;
  end

  assign clk_o = ungated_output_clk && clk_en;

endmodule
