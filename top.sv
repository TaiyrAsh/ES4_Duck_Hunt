module top(
    input logic extern_clk,
    output logic hsync,
    output logic vsync,
    output logic [5:0] RGB,
    input logic trigger,
    input logic detect,
    input logic reset,
    output logic debug
);



    logic clk;
    logic [9:0] row_count;
    logic [9:0] col_count;
    logic screen_reset;

    logic valid;
    logic debug_next;
    // always_ff @(posedge detect) begin
    //     debug <= 1;
    // end

    always_comb begin
        // if(!reset) debug_next = 0;
        // if(detect) debug_next = 1;
        // else debug_next = debug;
        debug = detect;
    end


    mypll mypll1(.clock_in(extern_clk), .clock_out(clk));
    vga myvga1(.clk(clk), .hsync(hsync), .vsync(vsync), .row_count(row_count), .col_count(col_count), .valid(valid), .reset(screen_reset));
    //c25_to_60fps clocktrans(.clk25m(extern_clk), .tick60(fps60));
    pattern_gen mypg(.valid(valid), .screen_reset(screen_reset), .col(col_count), .row(row_count), .RGB(RGB), .trigger(trigger), .clk(clk));

endmodule