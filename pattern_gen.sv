module pattern_gen (
    input logic valid,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic trigger,
    input logic clk,
    input logic screen_reset,
    output logic [5:0] RGB,
    input logic detect
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

    // Timer for landed state
    logic [7:0] landed_timer = 0;
    localparam LANDED_DELAY = 60;

    typedef enum {FLYING, HIT, LANDED} duck_state_t;
    duck_state_t duck_state = FLYING;
    duck_state_t duck_next_state;

    always_comb begin
        duck_next_state = duck_state;
        case(duck_state)
            FLYING: begin
                if(detect && state == WHITE_SCREEN) begin
                    duck_next_state = HIT;
                end
                end
            HIT: begin
                if(box_t >= SCREEN_HEIGHT - BOX_HEIGHT) begin
                    duck_next_state = LANDED;
                end
                end
            LANDED: begin
                if(landed_timer >= LANDED_DELAY) begin
                    duck_next_state = FLYING;
                end
            end
        endcase
    end

        // State register and timer


    always_ff @(posedge screen_reset) begin
        // Update state
        duck_state <= duck_next_state;
    
    // Timer logic - check what state we're GOING to
        if (duck_next_state == LANDED) begin
            landed_timer <= landed_timer + 1;
        end else begin
            landed_timer <= 0;
        end
        case(duck_state)
            FLYING: begin
                if (forward) begin
                //checking box_l to hs to see next posistion before moving
                    if (box_l + hs >= SCREEN_WIDTH - BOX_WIDTH) begin
                    box_l <= SCREEN_WIDTH - BOX_WIDTH;
                        forward <= 0;
                    end else begin
                        box_l <= box_l + hs;
                    end
                end else begin
            //to prevent wraparound so it doesnt go off screen
                    if (box_l < hs) begin
                        box_l <= 0;
                        forward <= 1;
                    end else begin
                        box_l <= box_l - hs;  // SUBTRACT when moving backward
                    end
                end
// Vertical movement
                if (down) begin
         // MOVE DOWN (subtract)
         //checking box_t + vs to see next position so it dont go off screen
                    if (box_t + vs >= SCREEN_HEIGHT - BOX_HEIGHT) begin
                        box_t <= SCREEN_HEIGHT - BOX_HEIGHT; //set box to the top of screen 
                        down <= 0;  //go down
                    end else begin
                        box_t <= box_t + vs;  // add to move down so you start going down
                    end
                end else begin
            //comparing top to vs is so there's no wraparound (box_t after subtracting would go negative and bc it is unsigned would go to 1023)
                    if (box_t < vs) begin
                        box_t <= 0;
                        down <= 1;  // Hit top, now go down
                    end else begin
                        box_t <= box_t - vs;  // SUBTRACT to move up
                    end
                end
                end
            HIT: begin
                // Fall straight down
                if (box_t + vs >= SCREEN_HEIGHT - BOX_HEIGHT) begin
                    box_t <= SCREEN_HEIGHT - BOX_HEIGHT;
                end else begin
                    box_t <= box_t + vs;
                end
                box_l <= box_l;  // Stay in place horizontally
            end
            LANDED: begin
                if (landed_timer >= LANDED_DELAY) begin
                    // Reset position for next round
                    box_l <= 0;
                    box_t <= 480;  // Start near top
                    forward <= 1;
                    down <= 1;
                end
            end
            endcase
    end
    


    // Calculate box boundaries using box_x
    logic [9:0] box_l = 0;
    logic [9:0] box_r;
    logic [9:0] box_t = 430;
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