/* this module is instantiated twice in the stereo_filter_warpper module 
    one for left and one for right
    */
module configurable_filter #(
    parameter DATA_WIDTH = 32,
    parameter FILTER_ORDER = 4
)(
    input                               clk,
    input                               reset,
    input                               enable,
    input [2:0]                         coefficient_select,
    input signed [DATA_WIDTH-1:0]       audio_in,
    output reg signed [DATA_WIDTH-1:0]  audio_out
);

    // Register array to store previous samples
    reg signed [DATA_WIDTH-1:0] delay_line [0:FILTER_ORDER-1];
    reg signed [DATA_WIDTH+8-1:0] weighted_sum; // scaled up to keep precision
    reg signed [DATA_WIDTH-1:0] delay_line_average;
    
    wire [7:0] coefficient;
    integer i;
    
    // Coefficient mapper instance
    coefficient_mapper coeff_map(
        .coefficient_select(coefficient_select),
        .coefficient(coefficient)
    );
    
    always @(posedge clk) begin
        if (reset) begin
            // Reset all registers
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                delay_line[i] <= 0;
            end
            audio_out <= 0;
            weighted_sum <= 0;
            delay_line_average <= 0;
        end
        else if (enable) begin
            // Shift new sample into delay line (update the array)
            for (i = FILTER_ORDER-1; i > 0; i = i - 1) begin
                delay_line[i] <= delay_line[i-1];
            end
            delay_line[0] <= audio_in;
            
            // Calculate average of all samples in delay line
            delay_line_average <= 0;
            for (i = 0; i < FILTER_ORDER; i = i + 1) begin
                delay_line_average <= delay_line_average + (delay_line[i] / FILTER_ORDER);
            end
            
            //The larger the coefficient, the more weight is given to
            // the average of past samples and less weight to the new sample, resulting in a smoother output.
            // Calculate weighted sum using average instead of just oldest sample
            weighted_sum <= (audio_in * (8'd255 - coefficient) + 
                           delay_line_average * coefficient);
            
            // Scale output back to original range
            audio_out <= weighted_sum[DATA_WIDTH+8-1:8]; // essentially dividing my 2^8 

        end
        else begin
            audio_out <= audio_in;
        end
    end

endmodule