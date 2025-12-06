// module get_duck_rom_data  (
//     input  logic clk,
//     input  logic [9:0] pixel_addr,
//     output logic [3:0] rgbmap
// );
//     logic [3:0] mem [0:7499];

//     // // Hardcode a checkerboard pattern
//     // initial begin
//     //     for (int i = 0; i < 7500; i++) begin
//     //         if ((i / 150 + i % 150) % 2 == 0)
//     //             mem[i] = 4'h5;  // white
//     //         else
//     //             mem[i] = 4'h4;  // black
//     //     end
//     // end

//     always_ff @(posedge clk) begin
//         rgbmap <= mem[pixel_addr];
//     end

// endmodule
module get_pin_rom_data(
    input  logic clk,
    input  logic [12:0] pixel_addr,
    output logic [3:0] rgbmap
);

    logic [3:0] mem [0:7499];  // 150 * 50 = 7500 pixels

    initial begin
        $readmemh("pin_sprite.taiyr", mem);
    end

    always_ff @(posedge clk) begin
        rgbmap <= mem[pixel_addr];
    end

endmodule


// module duck_sprites_gen (
//     input logic rst,
//     input logic [9:0] hcount,
//     input logic [9:0] vcount,
//     input logic [9:0] box_l,
//     input logic [9:0] box_t,
//     input logic clk,
//     output logic [5:0] rgb
// );
//     logic [3:0] rgbmap;
    
//     // Sprite sheet parameters
//     parameter IMG_WIDTH = 150;     // full sprite sheet width
//     parameter SPRITE_WIDTH = 50;   // single sprite width
//     parameter SPRITE_INDEX = 0;    // 0=first, 1=second, 2=third
    
//     // Calculate position within the sprite
//     logic [9:0] sprite_x;
//     logic [9:0] sprite_y;
//     logic [12:0] pixel_addr;
    
//     assign sprite_x = hcount - box_l;  // 0 to 49
//     assign sprite_y = vcount - box_t;  // 0 to 49
    
//     // Address into 150-wide sprite sheet
//     // row * 150 + column + sprite_offset
//     assign pixel_addr = (sprite_y * IMG_WIDTH) + sprite_x + (SPRITE_INDEX * SPRITE_WIDTH);

//     get_duck_rom_data #(.ADDR_BITS(13)) rom (
//         .clk(clk), 
//         .pixel_addr(pixel_addr),
//         .rgbmap(rgbmap)
//     );

//     always_comb begin
//         case(rgbmap) 
//             4'h0: rgb = 6'b110011;
//             4'h1: rgb = 6'b000100;
//             4'h2: rgb = 6'b101010;
//             4'h3: rgb = 6'b110000;
//             4'h4: rgb = 6'b000000;
//             4'h5: rgb = 6'b111111;
//             4'h6: rgb = 6'b010000;
//             4'h7: rgb = 6'b010101;
//             4'h8: rgb = 6'b111000;
//             default: rgb = 6'b000000;
        
//         endcase
//     end

// endmodule

module pin_sprites_gen (
    input logic rst,
    input logic [9:0] hcount,
    input logic [9:0] vcount,
    input logic [12:0] addr,
    input logic clk,
    output logic [5:0] rgb
);
    logic [3:0] rgbmap;
    
    // parameter IMG_WIDTH = 150;
    // parameter SPRITE_WIDTH = 50;
    // parameter SPRITE_INDEX = 0;
    
    // logic [9:0] sprite_x;
    // logic [9:0] sprite_y;
    // logic [12:0] pixel_addr;
    
    // // Register the inputs to align with ROM delay
    // logic [9:0] hcount_d, vcount_d, box_l_d;
    
    // always_ff @(posedge clk) begin
    //     hcount_d <= hcount;
    //     vcount_d <= vcount;
    //     box_l_d <= box_l;

    // end
    
    // assign sprite_x = hcount - box_l;
    // // assign sprite_y = vcount - box_t;
    // assign pixel_addr = (sprite_y * IMG_WIDTH) + sprite_x + (SPRITE_INDEX * SPRITE_WIDTH);

    get_pin_rom_data rom (
        .clk(clk), 
        .pixel_addr(addr),
        .rgbmap(rgbmap)
    );

    always_comb begin
    case(rgbmap) 
        4'h0: rgb = 6'b110011;  // (11, 00, 11) magenta
        4'h1: rgb = 6'b101010;  // (10, 10, 10) gray
        4'h2: rgb = 6'b100100;  // (10, 01, 00) brown
        4'h3: rgb = 6'b110000;  // (11, 00, 00) red
        4'h4: rgb = 6'b000000;  // (00, 00, 00) black
        4'h5: rgb = 6'b111111;  // (11, 11, 11) white
        4'h6: rgb = 6'b100000;  // (10, 00, 00) dark red
        4'h7: rgb = 6'b010101;  // (01, 01, 01) dark gray
        4'h8: rgb = 6'b111000;  // (11, 10, 00) orange
        4'h9: rgb = 6'b111000;  // (11, 10, 00) orange
        default: rgb = 6'b000000;
    endcase
end

endmodule