`timescale 1ns/10ps
module tb_serial_parallel;

	reg clk_i;
	reg clk_en_i;
	reg rst_ni;
	wire parallel_valid_o;
	reg parallel_ready_i;
	wire [8-1:0] parallel_o;
	reg serial_i;
	
	serial_parallel #(
		.WORD_WIDTH(8)
	) dut (
		.*
	);

	always #5 clk_i = ~clk_i;
	
	initial begin
		clk_i = 0;
		clk_en_i = 1;
		rst_ni = 0;
		parallel_ready_i = 0;
		repeat(10) @(posedge clk_i);
		rst_ni <= 1;
		serial_i <= 1;
		fork
			begin
				repeat(20) begin
					@(posedge clk_i);
					serial_i <= ~serial_i;
				end
			end
			begin
				repeat(2) begin
					@(posedge clk_i);
					while(~parallel_valid_o) @(posedge clk_i);
					parallel_ready_i <= 1;
					@(posedge clk_i);
					parallel_ready_i <= 0;
				end
			end      
		join
		repeat(10) @(posedge clk_i);
		$finish;
	end
		
	
endmodule