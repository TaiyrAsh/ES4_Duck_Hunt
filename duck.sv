module get_duck_rom_data(
    input  logic clk,
    input  logic [12:0] pixel_addr,
    output logic [3:0] rgbmap
);

    logic [3:0] mem [0:7499];  // 150 * 50 = 7500 pixels

    initial begin
        $readmemh("duck_sprite.taiyr", mem);
    end

    always_ff @(posedge clk) begin
        rgbmap <= mem[pixel_addr];
    end

endmodule



module duck_sprites_gen (
    input logic rst,
    input logic [9:0] hcount,
    input logic [9:0] vcount,
    input logic [12:0] addr,
    input logic clk,
    output logic [5:0] rgb
);
    logic [3:0] rgbmap;


    get_duck_rom_data rom (
        .clk(clk), 
        .pixel_addr(addr),
        .rgbmap(rgbmap)
    );

    always_comb begin
        case(rgbmap) 
            4'h0: rgb = 6'b110011;  // (11, 00, 11) magenta
            4'h1: rgb = 6'b000100;  // (00, 01, 00) dark green
            4'h2: rgb = 6'b101010;  // (10, 10, 10) gray
            4'h3: rgb = 6'b000000;  // (00, 00, 00) black
            4'h4: rgb = 6'b111111;  // (11, 11, 11) white
            4'h5: rgb = 6'b010000;  // (01, 00, 00) dark red
            4'h6: rgb = 6'b010101;  // (01, 01, 01) dark gray
            4'h7: rgb = 6'b111000;  // (11, 10, 00) orange
            default: rgb = 6'b000000;
        endcase
    end

endmodule