`timescale 1ns/10ps
module tb_sp_arbiter();
	reg [3:0] req;
	wire [3:0] gnt0;
	wire [3:0] gnt1;
	
	sp_arbiter #(
		.NUM(4),
		.LSB_HIGH(1)
	) dut0 (.req(req), .gnt(gnt0));
	
	sp_arbiter #(
		.NUM(4),
		.LSB_HIGH(0)
	) dut1 (.req(req), .gnt(gnt1));
	
	initial begin
		req = 4'b0001;
		repeat(20) begin
			#10 req = $urandom();
		end
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();
	end

endmodule