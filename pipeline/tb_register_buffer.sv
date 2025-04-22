`timescale 1ns/10ps

module tb_register_buffer();
	reg clk_i;
	reg rst_ni;
	reg clear_i;
	reg valid_i;
	wire ready_o;
	reg [8-1:0] data_i;
	wire valid_o;
	reg ready_i;
	wire [8-1:0] data_o;
	
	wire ready_o_skid;
	wire valid_o_skid;
	wire [8-1:0] data_o_skid;
	
	
	stream_register #(.DW(8)) buffer (.*);
	
	register_skid_buffer #(.DW(8)) skid_buffer (
		.*, 
		.ready_o(ready_o_skid),
		.valid_o(valid_o_skid),
		.data_o(data_o_skid)
	);

	always #5 clk_i = ~clk_i;

	always @(posedge clk_i or negedge rst_ni) begin
		if(~rst_ni) begin
			ready_i <= 0;
		end else begin
			ready_i <= $urandom();
		end
	end
	
	initial begin
		clk_i = 0;
		rst_ni = 0;
		clear_i = 0;
		valid_i = 0;
		repeat(10) @(posedge clk_i);
		rst_ni <= 1;
		valid_i <= 1;
		data_i <= $urandom();
		@(posedge clk_i);
		fork
			while(~ready_o) @(posedge clk_i);
			while(~ready_o_skid) @(posedge clk_i);
		join
		valid_i <= 0;
		repeat(10) @(posedge clk_i);
		$finish();
	end
	
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars();
	end
endmodule