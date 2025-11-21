module c25_to_60fps (
    input  logic clk25m,
    output logic tick60        // 1-cycle pulse at 60 Hz
);

    // 25.125 MHz / 60 Hz = 418,750 clock cycles
    localparam int DIV_COUNT = 418_750;

    logic [18:0] count;  // 19-bit counter

    always_ff @(posedge clk25m) begin
        if (reset) begin
            count  <= 0;
            tick60 <= 0;
        end else begin
            tick60 <= 0;                 // default each cycle (pulse is 1 clock long)

            if (count == DIV_COUNT - 1) begin
                count  <= 0;
                tick60 <= 1;             // pulse high for one 25.125 MHz clock
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
