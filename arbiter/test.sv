`timescale 1ns / 1ps
module test();

	reg [4-1:0]          input_unencoded;
	wire                 output_valid;
	wire [$clog2(4)-1:0] output_encoded;
	wire [4-1:0]         output_unencoded;


	priority_encoder #(
		.WIDTH(4),
		.LSB_HIGH_PRIORITY(0)
	) dut(
		.*
	);
	
	initial begin
		repeat(100) begin
			#10 input_unencoded = $urandom();
		end
		$finish;
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();
	end
endmodule