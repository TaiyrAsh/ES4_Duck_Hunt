module pattern_gen (
    input logic valid,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic trigger,
    input logic clk60,
    output logic [5:0] RGB
);

    logic [5:0] color = 6'b111111; // Initialize to white
    logic trigger_prev = 1'b0;     // Store previous trigger state
    logic flash = 1'b0;            // Flash state: 1 = show black this frame

    // Sequential: detect trigger and flash black for exactly one frame
    always_ff @(posedge clk60) begin
        trigger_prev <= trigger;
        
        // Detect rising edge of trigger
        if(trigger && !trigger_prev) begin
            flash <= 1'b1;  // Schedule a black frame
        end else if(flash) begin
            flash <= 1'b0;  // Clear after one frame
        end
        
        // Set color based on flash state
        if(flash)
            color <= 6'b000000; // Black during flash
        else
            color <= 6'b111111; // White otherwise
    end

    // Combinational: drive RGB based on col/valid
    always_comb begin
        if (col < 640 && valid) 
            RGB = color; 
        else 
            RGB = 6'd0;
    end

endmodule