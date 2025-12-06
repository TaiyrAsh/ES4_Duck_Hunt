module get_number_rom_data(
    input  logic clk,
    input  logic [9:0] pixel_addr,
    output logic rgbmap
);

    logic mem [0:599];  // 600 pixels

    initial begin
        $readmemh("numbers_sprite.samuel", mem);
    end

    always_ff @(posedge clk) begin
        rgbmap <= mem[pixel_addr];
    end

endmodule


module number_sprites_gen (
    input logic rst,
    input logic [9:0] hcount,
    input logic [9:0] vcount,
    input logic [9:0] addr,
    input logic clk,
    output logic [5:0] rgb
);
    logic rgbmap;
    

    get_number_rom_data rom (
        .clk(clk), 
        .pixel_addr(addr),
        .rgbmap(rgbmap)
    );

    always_comb begin
    case(rgbmap) 
        1'h0: rgb = 6'b110011;  // (11, 00, 11) magenta
        1'h1: rgb = 6'b000000;  // (00, 00, 00) black
        default: rgb = 6'b000000;
    endcase
end

endmodule