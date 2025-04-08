`timescale 1ns/10ps
module tb_parallel_serial;

	reg clk_i;
	reg clk_en_i;
	reg rst_ni;
	reg parallel_valid_i;
	wire parallel_ready_o;
	reg [8-1:0] parallel_i;
	wire serial_o;
	
	parallel_serial #(
		.WORD_WIDTH(8)
	) dut (
		.*
	);

	always #5 clk_i = ~clk_i;
	
	initial begin
		clk_i = 0;
		clk_en_i = 1;
		rst_ni = 0;
		parallel_valid_i = 0;
		repeat(10) @(posedge clk_i);
		rst_ni <= 1;
		repeat(2) begin
			parallel_valid_i <= 1;
			parallel_i <= $urandom();
			@(posedge clk_i);
			while(~parallel_ready_o) @(posedge clk_i);
			parallel_valid_i <= 0;
		end
		repeat(10) @(posedge clk_i);
		$finish;
	end
		
	
endmodule