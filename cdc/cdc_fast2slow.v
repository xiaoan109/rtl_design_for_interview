module cdc_fast2slow(
    input wire clk1_i,
    input wire rst1_ni,
    input wire data_i,
    input wire clk2_i,
    input wire rst2_ni,
    output wire data_o,
    output wire cdc_busy
);

    // data hold & clear
    reg data_clk1_latch;
    wire data_clk1_clr;

    always @(posedge clk1_i or negedge rst1_ni) begin
        if(~rst1_ni) begin
            data_clk1_latch <= 1'b0;
        end else if(data_clk1_clr) begin
            data_clk1_latch <= 1'b0;
        end else if(data_i) begin
            data_clk1_latch <= 1'b1;
        end
    end

    // back to back
    reg data_clk2_r;
    reg data_clk2_r1;
    always @(posedge clk2_i or negedge rst2_ni) begin
        if(~rst2_ni) begin
            data_clk2_r <= 1'b0;
            data_clk2_r1 <= 1'b0;
        end else begin
            data_clk2_r <= data_clk1_latch;
            data_clk2_r1 <= data_clk2_r;
        end
    end

    // edge detect
    reg data_clk2_r2;
    always @(posedge clk2_i or negedge rst2_ni) begin
        if(~rst2_ni) begin
            data_clk2_r2 <= 1'b0;
        end else begin
            data_clk2_r2 <= data_clk2_r1;
        end
    end

    assign data_o = ~data_clk2_r2 & data_clk2_r1;


    // data_o latch hold & clear
    reg data_clk2_latch;
    wire data_clk2_clr;

    always @(posedge clk2_i or negedge rst2_ni) begin
        if(~rst2_ni) begin
            data_clk2_latch <= 1'b0;
        end else if(~data_clk2_r1) begin
            data_clk2_latch <= 1'b0;
        end else if(data_o) begin
            data_clk2_latch <= 1'b1;
        end
    end

    // back to back feedback
    reg data_clk1_r;
    reg data_clk1_r1;
    always @(posedge clk1_i or negedge rst1_ni) begin
        if(~rst1_ni) begin
            data_clk1_r <= 1'b0;
            data_clk1_r1 <= 1'b0;
        end else begin
            data_clk1_r <= data_clk2_latch;
            data_clk1_r1 <= data_clk1_r;
        end
    end

    assign data_clk1_clr = data_clk1_r1;

    assign cdc_busy = data_clk1_latch || data_clk1_r1;

endmodule
