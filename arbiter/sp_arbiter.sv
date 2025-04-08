module sp_arbiter #(
    parameter NUM = 4,
    parameter LSB_HIGH = 1
) (
    input wire [NUM-1:0] req_i,
    output wire [NUM-1:0] gnt_o
);
wire [NUM-1:0] tmp_w;
assign tmp_w = LSB_HIGH ? {tmp_w[NUM-2:0] | req_i[NUM-2:0], 1'b0} : {1'b0, tmp_w[NUM-1:1] | req_i[NUM-1:1]};
assign gnt_o = ~tmp_w & req_i;	

// non-parameterized always + case
// ex.
//case语句会被综合成串行结构
//	always@(*)begin
//		case(1'b1)
//			req[3] : gnt = 4'b1000;
//			req[2] : gnt = 4'b0100;
//			req[1] : gnt = 4'b0010;
//			req[0] : gnt = 4'b0001;
//			default: gnt = 4'b0000;
//		endcase
//	end

//此处也可以使用if-else结构
//	always@(*)begin
//		if(req[3]) 
//			gnt = 4'b1000;
//		else if(req[2])
//			gnt = 4'b0100;
//		else if(req[1])
//			gnt = 4'b0010;
//		else if(req[1])
//			gnt = 4'b0001;
//		else
//			gnt = 4'b0000;
//	end
//
// 或者使用这样的方式
// reg [NUM-1:0] pre_req_r;
// reg [NUM-1:0] gnt_r;
// integer i;

// always @(*) begin
//     pre_req_r[0] = req[0];
//     gnt_r[0] = req[0];
//     for(i = 1; i<NUM; i=i+1) begin
//         gnt_r[i] = req[i] &  !pre_req_r[i-1];
//         pre_req_r[i] = req[i] | pre_req_r[i-1];
//     end
// end
// assign gnt = gnt_r;
endmodule
