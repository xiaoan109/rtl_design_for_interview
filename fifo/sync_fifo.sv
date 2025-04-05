module sync_fifo #(
    parameter DW = 8,
    parameter DEPTH = 8, // must bigger than 0
    parameter FALL_THROUGH = 0,
    parameter ADDR_DEPTH = (DEPTH > 1) ? $clog2(DEPTH) : 1
) (
    input wire clk_i,
    input wire rst_ni,
    input wire [DW-1:0] data_i,
    input wire push_i,
    output wire [DW-1:0] data_o,
    input wire pop_i,
    output wire full_o,
    output wire empty_o
);

    reg [ADDR_DEPTH-1:0] write_ptr_r;
    reg [ADDR_DEPTH-1:0] read_ptr_r;
    reg [ADDR_DEPTH:0] status_cnt_r;
    reg [DW-1:0] mem [DEPTH-1:0];
    reg [DW-1:0] data_r;
    integer i;

    assign full_o  =(status_cnt_r == DEPTH[ADDR_DEPTH:0]);
    assign empty_o = (status_cnt_r == 0) && ~(FALL_THROUGH && push_i);

    always @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            write_ptr_r <= 0;
        end else if(push_i && ~full_o) begin
            if(write_ptr_r == DEPTH[ADDR_DEPTH-1:0] - 1) begin
                write_ptr_r <= 0;
            end else begin
                write_ptr_r <= write_ptr_r + 1;
            end
        end
        // last assignment wins
        if(FALL_THROUGH && (status_cnt_r == 0) && push_i && pop_i) begin
            write_ptr_r <= write_ptr_r;
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            read_ptr_r <= 0;
        end else if(pop_i && ~empty_o) begin
            if(read_ptr_r == DEPTH[ADDR_DEPTH-1:0] - 1) begin
                read_ptr_r <= 0;
            end else begin
                read_ptr_r <= read_ptr_r + 1;
            end
        end
        // last assignment wins
        if(FALL_THROUGH && (status_cnt_r == 0) && push_i && pop_i) begin
            read_ptr_r <= read_ptr_r;
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            status_cnt_r <= 0;
        end else begin
            if(push_i && ~full_o) begin
                status_cnt_r <= status_cnt_r + 1;
            end
            if(pop_i && ~empty_o) begin
                status_cnt_r <= status_cnt_r - 1;
            end
            if(push_i && ~full_o && pop_i && ~empty_o) begin
                status_cnt_r <= status_cnt_r;
            end
            if(FALL_THROUGH && (status_cnt_r == 0) && push_i && pop_i) begin
                status_cnt_r <= status_cnt_r;
            end
        end
    end

    always @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            for(i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <=0;
            end
        end else if(push_i && ~full_o) begin
            mem[write_ptr_r] <= data_i;
        end
    end

    always @(*) begin
        data_r = mem[read_ptr_r];
        if(FALL_THROUGH && (status_cnt_r == 0) && push_i) begin
            data_r = data_i;
        end
    end

    assign data_o = data_r;
endmodule