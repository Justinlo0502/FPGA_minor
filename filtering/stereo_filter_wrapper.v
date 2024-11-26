module stereo_filter_wrapper(
    input                       clk,
    input                       reset,
    input                       enable, // SW[0]
    input [2:0]                coefficient_select, //SW[1-3]
    input signed [31:0]        left_audio_in,
    input signed [31:0]        right_audio_in,
    output signed [31:0]       left_audio_out,
    output signed [31:0]       right_audio_out,
    // Debug outputs
    output [7:0]               debug_coefficient,
    output signed [31:0]       debug_last_sample
);

    configurable_filter #(
        .DATA_WIDTH(32),
        .FILTER_ORDER(4)
    ) left_filter (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .coefficient_select(enable),
        .audio_in(left_audio_in),
        .audio_out(left_audio_out),
        .debug_coefficient(debug_coefficient),
        .debug_last_sample(debug_last_sample)
    );

    configurable_filter #(
        .DATA_WIDTH(32),
        .FILTER_ORDER(4)
    ) right_filter (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .coefficient_select(coefficient_select),
        .audio_in(right_audio_in),
        .audio_out(right_audio_out)
    );

endmodule