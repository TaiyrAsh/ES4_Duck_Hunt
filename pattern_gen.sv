module pattern_gen (
    input logic valid,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic trigger,
    input logic clk,
    input logic screen_reset,
    output logic [5:0] RGB,
);
    logic [5:0] color;
    logic [5:0] b_color;
    //TODO: ROM Module here: row,col,clock as input -> RGB output
    sprites_gen spgen(.rst(screen_reset), .hcount(col), .vcount(row), .clk(clk), .rgb(b_color));
    
    
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
            IDLE:  begin
                if (trigger) next_state = BLACK_SCREEN;
                else next_state = state;
            end
            HELD:           begin
                if (trigger) next_state = state;
                else next_state = IDLE;
            end
            BLACK_SCREEN:   next_state = WHITE_SCREEN;
            WHITE_SCREEN:   next_state = HELD;
            default:        next_state = state;
        endcase


        // Output logic
        case(state)       
            BLACK_SCREEN:   color = 6'b000000;
            WHITE_SCREEN:   color = 6'b111111;
            //TODO: replace default with 
            default:        color = b_color;
        endcase

        if (valid) 
            RGB = color;
        else 
            RGB = 6'd0;
    end

endmodule