module get_rom_data #(
    parameter ADDR_BITS = 10   // number of address bits
) (
    input  logic clk,
    input  logic [ADDR_BITS-1:0] pixel_addr,
    output logic [5:0] rgb      // 6-bit RGB output
);

    // BRAM array: 2^ADDR_BITS entries of 6 bits each
    logic [5:0] mem [0:(1<<ADDR_BITS)-1];

    // Load binary memory file
    initial begin
        $readmemb("background.binmem", mem);
    end

    // Synchronous read (required for BRAM inference)
    always_ff @(posedge clk) begin
        rgb <= mem[pixel_addr];
    end

endmodule


module sprites_gen (
    input logic rst,
    input logic [9:0] hcount,  // 0..656
    input logic [9:0] vcount,  // 0..490
    input logic clk,
    output logic [5:0] rgb
);

    logic [ADDR_BITS-1:0] pixel_addr;
    parameter ADDR_BITS = 10;

    
    // 8×8 tiles → find which tile we're in
    logic [6:0] tile_x;     // 0..79
    logic [5:0] tile_y;     // 0..59
    logic [ADDR_BITS-1:0] tile_addr; 
    logic [5:0] tile_color;

    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         hcount <= 0;
    //         vcount <= 0;
    //     end 
    //     else begin
    //         if (hcount == 639) begin // Pixel length of image
    //             hcount <= 0;
    //             if (vcount == 479) // Pixel width of image
    //                 vcount <= 0;
    //             else
    //                 vcount <= vcount + 1;
    //         end 
    //         else hcount <= hcount + 1;
    //     end
    // end

    assign tile_x = hcount / 8;     // OR hcount >> 3
    assign tile_y = vcount / 8;     // OR vcount >> 3

    // tile address
    assign tile_addr = tile_y * 8 + tile_x; // times 80 or 8?

    assign rgb = tile_color;

endmodule