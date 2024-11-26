module waveform_generator(
    input CLOCK_50,
    input [18:0] note_period,    // This is actually the HALF period
    input [1:0] wave_select,
    input note_enable,
    output reg signed [31:0] wave_out
);
    parameter AMPLITUDE = 32'd10000000;
    reg [18:0] phase_counter;
    
    // Double the input period to get the full period
    wire [19:0] full_period = {note_period, 1'b0}; // Multiply by 2
    
    always @(posedge CLOCK_50) begin
        // Use full_period for the counter reset
        if (phase_counter >= full_period)
            phase_counter <= 0;
        else
            phase_counter <= phase_counter + 1;

        if (!note_enable)
            wave_out <= 0;
        else begin
            case (wave_select)
                2'b00: begin // Regular Square (50% duty cycle)
                    wave_out <= (phase_counter < note_period) ?  // Compare with half period
                               AMPLITUDE : -AMPLITUDE;
                end
                
                2'b01: begin // Quarter Square (25% duty cycle)
                    wave_out <= (phase_counter < (note_period >> 1)) ? 
                               AMPLITUDE : -AMPLITUDE;
                end
                
                2'b10: begin // Low Volume Square
                    wave_out <= (phase_counter < note_period) ?  // Compare with half period
                               (AMPLITUDE >> 2) : -(AMPLITUDE >> 2);
                end
                
                2'b11: begin // Very Short Pulse
                    wave_out <= (phase_counter < (note_period >> 2)) ? 
                               AMPLITUDE : -AMPLITUDE;
                end
            endcase
        end
    end
endmodule