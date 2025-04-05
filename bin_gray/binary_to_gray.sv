module binary_to_gray #(
  parameter N = 1
) (
  input wire [N-1:0] A,
  output wire [N-1:0] Z
);

  assign Z = A ^ (A >> 1);
endmodule
