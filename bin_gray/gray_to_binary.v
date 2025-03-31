module gray_to_binary #(
  parameter N = 1
) (
  input wire [N-1:0] A,
  output wire [N-1:0] Z
);

genvar i;
generate
  for(i = 0; i < N; i = i + 1) begin
    assign z[i] = ^A[N-1:i];
  end
endgenerate

endmodule
