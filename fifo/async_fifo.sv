module async_fifo#(
    parameter DW = 8,
    parameter DEPTH = 8, // must bigger than 0
    parameter ADDR_DEPTH = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input wire wr_clk_i,
    input wire wr_rst_ni,
    input wire [DW-1:0] data_i,
    input wire push_i,
    input wire rd_clk_i,
    input wire rd_rst_ni,
    output wire [DW-1:0] data_o,
    input wire pop_i,
    output full_o,
    output empty_o
);

    reg [DW-1:0] mem[DEPTH-1:0];

    // binary pointer
    reg [ADDR_DEPTH:0] write_ptr_b_r;
    reg [ADDR_DEPTH:0] read_ptr_b_r;
    wire [ADDR_DEPTH-1:0] write_addr_w;
    wire [ADDR_DEPTH-1:0] read_addr_w;
    // gray pointer
    wire [ADDR_DEPTH:0] write_ptr_g_w;
    reg [ADDR_DEPTH:0] write_ptr_g_r;
    reg [ADDR_DEPTH:0] write_ptr_g_r1;
    wire [ADDR_DEPTH:0] read_ptr_g_w;
    reg [ADDR_DEPTH:0] read_ptr_g_r;
    reg [ADDR_DEPTH:0] read_ptr_g_r1;

    reg [DW-1:0] rd_data_r;
    integer i;

    always @(posedge wr_clk_i or negedge wr_rst_ni) begin
        if(~wr_rst_ni) begin
            write_ptr_b_r <= 0;
        end else if(push_i && ~full_o) begin
            write_ptr_b_r <= write_ptr_b_r + 1;
        end
    end

    always @(posedge rd_clk_i or negedge rd_rst_ni) begin
        if(~rd_rst_ni) begin
            read_ptr_b_r <= 0;
        end else if(pop_i && ~empty_o) begin
            read_ptr_b_r <= read_ptr_b_r + 1;
        end
    end

    assign write_addr_w = write_ptr_b_r[ADDR_DEPTH-1:0];
    assign read_addr_w = read_ptr_b_r[ADDR_DEPTH-1:0];


    always @(posedge wr_clk_i or negedge wr_rst_ni) begin
        if(~wr_rst_ni) begin
            for(i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= 0;
            end
        end else if(push_i && ~full_o) begin
            mem[write_addr_w] <= data_i;
        end
    end

    always @(posedge rd_clk_i or negedge rd_rst_ni) begin
        if(~rd_rst_ni) begin
            rd_data_r <= 0;
        end else if(pop_i && ~empty_o) begin
            rd_data_r <= mem[read_addr_w];
        end
    end

    assign write_ptr_g_w = write_ptr_b_r ^ (write_ptr_b_r >> 1);
    assign read_ptr_g_w = read_ptr_b_r ^ (read_ptr_b_r >> 1);

    // sync write ptr to read clock domain
    always @(posedge rd_clk_i or negedge rd_rst_ni) begin
        if(~rd_rst_ni) begin
            write_ptr_g_r <= 0;
            write_ptr_g_r1 <= 0;
        end else begin
            write_ptr_g_r <= write_ptr_g_w;
            write_ptr_g_r1 <= write_ptr_g_r;
        end
    end

    // sync read ptr to write clock domain
    always @(posedge wr_clk_i or negedge wr_rst_ni) begin
        if(~wr_rst_ni) begin
            read_ptr_g_r <= 0;
            read_ptr_g_r1 <= 0;
        end else begin
            read_ptr_g_r <= read_ptr_g_w;
            read_ptr_g_r1 <= read_ptr_g_r;
        end
    end

    assign empty_o = (write_ptr_g_w == read_ptr_g_r1);
    assign full_o = (read_ptr_g_w != write_ptr_g_r1) && (read_ptr_g_w[ADDR_DEPTH-1:0] == write_ptr_g_r1[ADDR_DEPTH-1:0]);
    assign data_o = rd_data_r;

endmodule