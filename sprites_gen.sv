module get_rom_data #(
    parameter ADDR_BITS = 13   // number of address bits
) (
    input  logic clk,
    input  logic [ADDR_BITS-1:0] pixel_addr,
    output logic [5:0] rgb      // 6-bit RGB output
);

    // BRAM array: 2^ADDR_BITS entries of 6 bits each
    logic [5:0] mem [(2**ADDR_BITS)-1:0]; //Unpacked array from index 0 up to 2**ADDR_BITS

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
    input logic [9:0] hcount,  // 0..656 col
    input logic [9:0] vcount,  // 0..490 row
    input logic clk,
    output logic [5:0] rgb
);

    parameter ADDR_BITS = 13; //change to correspond with number of lines of data being read in

    get_rom_data rom(.clk(clk), .pixel_addr(tile_addr), .rgb(rgb));
    // 8×8 tiles → find which tile we're in
    logic [6:0] tile_x;     // 80 tiles in x direction for 8x8 blocks
    logic [5:0] tile_y;     // 60 tiles in y direction for 8x8 blocks
    logic [ADDR_BITS-1:0] tile_addr; 

    assign tile_x = hcount[9:3]; //If 8x8 block of pixels, start from bit 3 (100 in binary is 8). if 16x16, start from bit 4
    assign tile_y = vcount[9:3]; 


    assign tile_addr = (tile_y * 80) + tile_x; // tile_x only increments on the 8 count of hcount because we're reading from the 4th bit
                                                //The integer value must match with the number of pixel blocks per line on screen

endmodule
