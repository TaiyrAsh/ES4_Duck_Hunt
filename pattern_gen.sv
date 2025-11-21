module pattern_gen (
    input logic valid,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic trigger,
    input logic clk,
    output logic [5:0] RGB
);
    logic [5:0] color;
    
    
    typedef enum {IDLE, TRIGGER_PULLED, BLACK_SCREEN, WHITE_SCREEN, HELD} state_t;
    
    // 1. Initialize the state here
    state_t state = IDLE;
    state_t next_state;

    always_ff @(posedge clk) begin
        state <= next_state;

        if (col == 0 && row == 0) begin
            case(trigger)       
                1:   color <= 6'b111111;
                0:   color <= 6'b000000;
                default:        color <= 6'b010110;
            endcase
        end
    end

    // always_comb begin
    //     // Default next_state to current state to prevent latches
    //     next_state = state; 

    //     // State transition logic
    //     if(trigger && state == IDLE) begin
    //         next_state = TRIGGER_PULLED;
    //     end else begin
    //         // Only transition at the start of a frame (row=0, col=0)
    //         if (col == 0 && row == 0) begin
    //             case (state)
    //                 TRIGGER_PULLED: next_state = BLACK_SCREEN;
    //                 HELD:           begin
    //                     if (trigger) next_state = state;
    //                     else next_state = IDLE;
    //                 end
    //                 BLACK_SCREEN:   next_state = WHITE_SCREEN;
    //                 WHITE_SCREEN:   next_state = HELD;
    //                 default:        next_state = state;
    //             endcase
    //         end
    //     end

    //     // Output logic
    //     case(state)       
    //         BLACK_SCREEN:   color = 6'b000000;
    //         WHITE_SCREEN:   color = 6'b111111;
    //         default:        color = 6'b010110;
    //     endcase

    //     if (col < 640 && valid) 
    //         RGB = color;
    //     else 
    //         RGB = 6'd0;
    // end

    always_comb begin

        // Output logic
        

        if (col < 640 && valid) 
            RGB = color;
        else 
            RGB = 6'd0;
    end

endmodule