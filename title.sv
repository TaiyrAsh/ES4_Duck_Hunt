module get_title_rom_data #(
    parameter ADDR_BITS = 15   // number of address bits
) (
    input  logic clk,
    input  logic [ADDR_BITS-1:0] pixel_addr,
    output logic [2:0] rgbmap      // 6-bit RGB output
);

    // BRAM array: 2^ADDR_BITS entries of 6 bits each
    logic [2:0] mem [0:19199]; //Unpacked array from index 0 up to 2**ADDR_BITS

    // Load binary memory file
    initial begin
        $readmemh("title.yong", mem);
    end

    // Synchronous read (required for BRAM inference)
    always_ff @(posedge clk) begin
        rgbmap <= mem[pixel_addr];
    end

endmodule


module title_gen (
    input logic rst,
    input logic [9:0] hcount,  // 0..656 col
    input logic [9:0] vcount,  // 0..490 row
    input logic clk,
    output logic [5:0] rgb
);
    logic [2:0] rgbmap;
    parameter ADDR_BITS = 15; //change to correspond with number of lines of data being read in

    get_title_rom_data rom(.clk(clk), .pixel_addr(tile_addr), .rgbmap(rgbmap));
    // 8×8 tiles → find which tile we're in
    logic [7:0] tile_x;     // 80 tiles in x direction for 8x8 blocks
    logic [7:0] tile_y;     // 60 tiles in y direction for 8x8 blocks
    logic [ADDR_BITS-1:0] tile_addr; 

    assign tile_x = hcount[9:2]; //If 8x8 block of pixels, start from bit 3 (100 in binary is 8). if 16x16, start from bit 4
    assign tile_y = vcount[9:2]; 


    assign tile_addr = (tile_y * 160) + tile_x; // tile_x only increments on the 8 count of hcount because we're reading from the 4th bit
                                                //The integer value must match with the number of pixel blocks per line on screen

    always_comb begin
        case(rgbmap) 
        2'h0: rgb = 6'b111111;  // magenta (transparent)
        2'h1: rgb = 6'b000000;  // black
        2'h2: rgb = 6'b110100;  // orange
        default: rgb = 6'b000000;
        endcase
    end

endmodule
