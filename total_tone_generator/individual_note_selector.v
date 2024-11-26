module individual_note_selector (
    input sel,
    input [1:0] octave_sel,
    input [18:0] note_period_low,
    input [18:0] note_period_high,
    output reg [18:0] output_period
);

    always @(*) begin
        if (sel && octave_sel[1])
            output_period = note_period_low;
        else if (sel && octave_sel[0])
            output_period = note_period_high;
        else
            output_period = 19'b0;
    end

endmodule

