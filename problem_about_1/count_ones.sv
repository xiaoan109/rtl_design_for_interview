module count_ones #(
    parameter DW = 8,
    parameter DW_SIZE = $clog2(DW) + 1
) (
    input wire [DW-1:0] data_i,
    output wire [DW_SIZE-1:0] count_o
);

  // TODO: sum or adder tree

  // clock based or simulate-only method :

  // result = 0;
  // while(A)begin
  //   A = A&(A-1);
  //   result++;
  // end



endmodule
