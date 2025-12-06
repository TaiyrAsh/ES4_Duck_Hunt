module top(
    input logic extern_clk,
    input logic trigger,
    input logic detect,
    input logic reset,

    output logic hsync,
    output logic vsync,
    output logic [5:0] RGB,
);

    logic clk;
    logic [9:0] row_count;
    logic [9:0] col_count;
    logic screen_reset;
    logic valid;

    

    mypll mypll1(.clock_in(extern_clk), .clock_out(clk));
    vga myvga1(.clk(clk), .hsync(hsync), .vsync(vsync), .row_count(row_count), .col_count(col_count), .valid(valid), .reset(screen_reset));
    pattern_gen mypg(
        .valid(valid), 
        .screen_reset(screen_reset), 
        .col(col_count), 
        .row(row_count), 
        .RGB(RGB), 
        .trigger(trigger), 
        .clk(clk), 
        .detect(detect)
    );

endmodule