module pattern_gen (
    input logic valid,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic trigger,
    input logic clk,
    input logic screen_reset,
    input logic detect,
    output logic [5:0] RGB
);
    logic [3:0] score;
    //main game state (start, in game, end)
    typedef enum {START, IN_GAME, IN_HELD} game_state_t;
    game_state_t game_state = START;
    game_state_t next_game_state;
    logic [2:0] hit_counter = 0;
    logic [7:0] frame_counter = 0;
    logic [1:0] sprite_index_reg = 0;
    logic [2:0] bullet_count;
    logic [5:0] color;
    logic [5:0] b_color;
    logic [5:0] t_color;
//vertical and horizontal speed of duck
    logic [5:0] vs = 3;
    logic [5:0] hs = 3;
//forward and down bits to control direction for duck "bouncing"
    logic forward = 1;
    logic down = 1;

    // Hit box parameters
    localparam BOX_WIDTH  = 50;
    localparam BOX_HEIGHT = 50;
    localparam SCREEN_WIDTH  = 640;
    localparam SCREEN_HEIGHT = 480;
    localparam SCORE_W = 6;
    localparam SCORE_H = 10;
    localparam SCORE_W_OFFSET = 25;
    localparam SCORE_H_OFFSET = 455;

    // Timer for landed state to reset
    logic [7:0] landed_timer = 0;
    localparam LANDED_DELAY = 120;
    // States for Duck State Machine
    typedef enum {FLYING, HIT, LANDED} duck_state_t;
    //initialize state
    duck_state_t duck_state = FLYING;
    duck_state_t duck_next_state;
    //duck state transitions
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
        if (state == BLACK_SCREEN && next_state == WHITE_SCREEN && !detect) begin
            bullet_count <= bullet_count - 1;
        end
        
        // Reset bullets on game start
        if (game_state == START && next_game_state == IN_GAME) begin
            bullet_count <= 7;
            score <= 0;
        end
        if(hit_counter == 0) begin
            vs <= 3;
            hs <= 3;
            end
        if (duck_state == HIT && duck_next_state == LANDED) begin
            hit_counter <= hit_counter + 1;
            score <= score + 1;
        end
        if (duck_state != (HIT || LANDED)) begin
            if(frame_counter[4]) begin
                sprite_index_reg = 1;
            end
            else begin
                sprite_index_reg = 0;
            end
            frame_counter <= frame_counter + 1;
            // Timer logic for duck reset
            if (frame_counter == 67 || frame_counter == 4) begin
                forward <= !forward;
            end
            if (duck_next_state == LANDED) begin
                landed_timer <= landed_timer + 1;
            end else begin
                landed_timer <= 0;
            end
        end
        else begin
            sprite_index_reg = 2;
        end
        if(state == IDLE || state == HELD) begin
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
                        box_t <= box_t + 2;
                    end
                    box_l <= box_l;  // Stay in place horizontally
                    //maybe warble logic? sway left to right as it falls

                end
                LANDED: begin
                    if (landed_timer >= LANDED_DELAY) begin
                        // Reset position for next round
                        forward <= 1;
                        down <= 1;
                        //increase movement speed
                        vs <= vs + 1;
                        hs <= hs + 1;
                    end
                end
            endcase
        end
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

// For actual pixel drawing (normal boundaries)
    logic in_num;
    assign in_num = (col >= SCORE_W_OFFSET) && (col < (SCORE_W + SCORE_W_OFFSET)) && 
                (row >= SCORE_H_OFFSET) && (row < (SCORE_H + SCORE_H_OFFSET));

// For address prefetch (1 pixel ahead)
    logic in_num_prefetch;
    assign in_num_prefetch = (col >= SCORE_W_OFFSET - 1) && (col < (SCORE_W + SCORE_W_OFFSET - 1)) && 
                         (row >= SCORE_H_OFFSET) && (row < (SCORE_H + SCORE_H_OFFSET));

    sprites_gen spgen(
        .rst(screen_reset),
        .hcount(col),
        .vcount(row),
        .clk(clk),
        .rgb(b_color)
    );
    title_gen titlegen(
        .rst(screen_reset),
        .hcount(col),
        .vcount(row),
        .clk(clk),
        .rgb(t_color)
    );
    duck_sprites_gen duckgen(
        .rst(screen_reset),
        .hcount(col),
        .vcount(row),
        .clk(clk),
        .rgb(duck_sprite),
        .addr(next_ds_address)
    );
    number_sprites_gen numbgen(
        .rst(screen_reset),
        .hcount(col),
        .vcount(row),
        .clk(clk),
        .rgb(score_sprite),
        .addr(next_s_address)
    );
    logic [12:0] next_ds_address;
    logic [9:0] next_s_address;
    logic [1:0] sprite_index = 0;
    logic [5:0] duck_sprite;
    logic [5:0] score_sprite;

    typedef enum {IDLE, BLACK_SCREEN, WHITE_SCREEN, HELD} state_t;
    state_t state = IDLE;
    state_t next_state;

    always_ff @(posedge screen_reset) begin
        state <= next_state;
        game_state <= next_game_state;
    end

    always_comb begin
        // Default next_state to current state to prevent latches
        next_state = state;
        color = 6'b000000;
        sprite_index = 0;
        next_ds_address = 0;
        next_s_address = 0;
        next_game_state = game_state;
        case(game_state) 
            START: begin
                if(trigger)
                    next_game_state = IN_GAME;
            end
            IN_GAME: begin
                if(bullet_count == 0)
                    next_game_state = IN_HELD;
            end
            IN_HELD: begin
                if(trigger)
                    next_game_state = game_state;
                else
                    next_game_state = START;
            end
            default: 
                next_game_state = game_state;
        endcase

        //trigger stuff for in game
        if(game_state == IN_GAME) begin
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
                default begin
                    next_state = state;
                    sprite_index = 0;
                end
            endcase
        end

        case(state)
            BLACK_SCREEN: begin
                color = 6'b000000;
                next_ds_address = 0;
                next_s_address = 0;
            end
            WHITE_SCREEN: begin
            if (in_box)
                color = 6'b111111;
            else
                color = 6'b000000;
                next_ds_address = 0;  // These two lines always execute!
                next_s_address = 0;
        end
            default: 
                if (game_state == IN_GAME) begin
                    if (in_box) begin
                        if (forward) begin
                            next_ds_address = ((row - box_t) * 150) + (col - box_l) + (sprite_index_reg * 50);
                        end
                        else begin
                            next_ds_address = ((row - box_t) * 150) + (49- (col - box_l)) + (sprite_index_reg * 50);
                        end

                        if(duck_sprite != 6'b110011) begin
                            color = duck_sprite;
                        end
                        else begin
                            color = b_color;
                        end
                        
                    end
                    else if (in_num) begin
                        next_s_address = ((row - SCORE_H_OFFSET) * 60) + (col - SCORE_W_OFFSET) + (score * 6);
                        if(score_sprite != 6'b110011) begin
                            color = score_sprite;
                        end
                        else begin
                            color = b_color;
                        end
                    end
                    else begin
                        color = b_color;
                        next_ds_address = 0;
                        next_s_address = 0;
                    end
                end else begin
                    color = t_color;
                end
        endcase
        
        

        if (valid)
            RGB = color;
        else
            RGB = 6'd0;
    end



endmodule