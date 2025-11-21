module top(
    input logic extern_clk,
    output logic hsync,
    output logic vsync,
    output logic [5:0] RGB,
    input logic trigger
);
    logic clk;
    logic [9:0] row_count;
    logic [9:0] col_count;

    logic valid;
    logic fps60;

    mypll mypll1(.clock_in(extern_clk), .clock_out(clk));
    vga myvga1(.clk(clk), .hsync(hsync), .vsync(vsync), .row_count(row_count), .col_count(col_count), .valid(valid));
    c25_to_60fps clocktrans(.clk25m(extern_clock), .tick60(fps60));
    pattern_gen mypg(.valid(valid), .col(col_count), .row(row_count), .RGB(RGB), .trigger(trigger), .clk60(fps60));

endmodule