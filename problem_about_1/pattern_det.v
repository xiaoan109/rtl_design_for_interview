module pattern_det(
  input wire [7:0] data_i,
  output wire [7:0] data_o
);

// data_i: 10010101 -> search 2nd "01" sequence
// data_o: 00000100

// detect toggle "01"
wire [7:0] tmp1 = data_i ^ (data_i >> 1);
// ignore MSB, it has no previous bit
wire [7:0] tmp2 = {1'b0, tmp1[6:0]};
// mask untoggled bits
wire [7:0] tmp3 = tmp2 & data_i;

// find first "01" (actually 1)
wire [7:0] tmp4 = {1'b0, tmp3[7:1] | tmp4[7:1]};
wire [7:0] tmp5 = ~tmp4 & tmp3;
// xor to clear the first "01"
wire [7:0] tmp6 = tmp5 ^ tmp3;

// find second "01" (actually 1)
wire [7:0] tmp7 = {1'b0, tmp6[7:1] | tmp7[7:1]};
wire [7:0] tmp8 = ~tmp7 & tmp6;


assign  data_o = tmp8;

endmodule
