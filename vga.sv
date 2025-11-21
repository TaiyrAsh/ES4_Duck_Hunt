module vga(
  input logic clk,
  output logic hsync,
  output logic vsync,
  output logic [9:0] col_count,
  output logic [9:0] row_count,
  output logic valid
);

    always_comb begin
        // hsync on for 0-656 off for 656-752 on for 752-800
        if (col_count < 656 | col_count >= 752) hsync = 1'b1;
        else hsync = 1'b0;

        // vsync on for 0-490 off for 490-492 on for 492-525
        if (row_count < 490 | row_count >= 492) vsync = 1'b1;
        else vsync = 1'b0;

        if(col_count < 640 && row_count < 480) valid = 1'b1;
        else valid = 1'b0;
    end
  
    always_ff @(posedge clk) begin
        if (col_count == 10'd800) begin
            col_count <= 10'd0;
            if (row_count == 10'd525) row_count <= 10'd0;
            else row_count <= row_count + 10'd1;
        end else begin
            col_count <= col_count + 10'd1;
        end
    end

endmodule