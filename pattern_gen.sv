module pattern_gen (
    input logic valid,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic trigger,
    input logic clk,
    input logic screen_reset,
    output logic [5:0] RGB
);

    logic [5:0] color;
    logic [5:0] b_color;

    logic [2:0] vs = 2;
    logic [2:0] hs = -5;

    logic forward = 1;
    logic down = 1;

    // Box parameters
    localparam BOX_WIDTH  = 50;
    localparam BOX_HEIGHT = 50;
    localparam SCREEN_WIDTH  = 640;
    localparam SCREEN_HEIGHT = 480;

    // Update box_x on each screen_reset
    always_ff @(posedge screen_reset) begin
        if (box_l >= SCREEN_WIDTH-BOX_WIDTH) begin
           // box_l <= box_l - hs;
            forward <= 0;
        end else if (box_l <= 0) begin
           // box_l <= box_l + hs;
            forward <= 1;
        end

        if (forward == 1) begin
            box_l <= box_l + hs;
        end else begin
            box_l <= box_l - hs;
        end

        if(box_t <= 0) begin
          // box_t <= box_t - vs;
            down <= 1;
        end else if (box_t >= SCREEN_HEIGHT-BOX_HEIGHT) begin
          // box_t <= box_t + vs;
            down <= 0;
        end

        if (down == 1) begin
            box_t <= box_t + vs;
        end else begin
            box_t <= box_t - vs;
        end

    end
        

    // Calculate box boundaries using box_x
    logic [9:0] box_l = 120;
    logic [9:0] box_r;
    logic [9:0] box_t = 120;
    logic [9:0] box_b;
    
   
    assign box_r = box_l + BOX_WIDTH;
    assign box_b = box_t + BOX_HEIGHT;
    
    // Check if current pixel is inside the box
    logic in_box;
    assign in_box = (col >= box_l) && (col < box_r) &&
                    (row >= box_t) && (row < box_b);

    sprites_gen spgen(
        .rst(screen_reset),
        .hcount(col),
        .vcount(row),
        .clk(clk),
        .rgb(b_color)
    );

    typedef enum {IDLE, BLACK_SCREEN, WHITE_SCREEN, HELD} state_t;
    state_t state = IDLE;
    state_t next_state;

    always_ff @(posedge screen_reset) begin
        state <= next_state;
    end

    always_comb begin
        // Default next_state to current state to prevent latches
        next_state = state;

        case (state)
            IDLE: begin
                if (trigger)
                    next_state = BLACK_SCREEN;
                else
                    next_state = state;
            end
            HELD: begin
                if (trigger)
                    next_state = state;
                else
                    next_state = IDLE;
            end
            BLACK_SCREEN: next_state = WHITE_SCREEN;
            WHITE_SCREEN: next_state = HELD;
            default: next_state = state;
        endcase

        // Output logic
        case(state)
            BLACK_SCREEN: color = 6'b000000;
            WHITE_SCREEN: begin
                if (in_box)
                    color = 6'b111111;
                else
                    color = 6'b000000;
            end
            default: if (in_box)
                    color = 6'b110000;
                else
                    color = b_color;
        endcase

        if (valid)
            RGB = color;
        else
            RGB = 6'd0;
    end

endmodule