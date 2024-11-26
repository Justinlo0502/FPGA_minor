module rev4 (
    // Inputs
    CLOCK_50,
    KEY,
    AUD_ADCDAT,
    GPIO_0,
    GPIO_1,
    SW,

    // Bidirectionals
    AUD_BCLK,
    AUD_ADCLRCK,
    AUD_DACLRCK,
    FPGA_I2C_SDAT,

    // Outputs
    AUD_XCK,
    AUD_DACDAT,
    FPGA_I2C_SCLK,

    HEX0,
    HEX1,
    HEX2,
    LEDR
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
// Define the 19-bit delays for each note from C4 to A4
parameter C4   = 19'b0010111010100000101;
parameter Cs4  = 19'b0010110000001001010;
parameter D4   = 19'b0010100110001111110;
parameter Ds4  = 19'b0010011101000100101;
parameter E4   = 19'b0010010100010110011;
parameter F4   = 19'b0010001100000010100;
parameter Fs4  = 19'b0010000111111011111;
parameter G4   = 19'b0001111101000111111;
parameter Gs4  = 19'b0001110101101100110;
parameter A4   = 19'b0001101110111110010;
parameter As4  = 19'b0001101001001001101;
parameter B4   = 19'b0001100011110111010;

// Define the 19-bit delays for each note from C5 to B5
parameter C5   = 19'b0001011101010000010;
parameter Cs5  = 19'b0001010111111100101;
parameter D5   = 19'b0001010011000111110;
parameter Ds5  = 19'b0001001110100010101;
parameter E5   = 19'b0001001010001011001;
parameter F5   = 19'b0001000110000001010;
parameter Fs5  = 19'b0001000011111101111;
parameter G5   = 19'b0000111110100011111;
parameter Gs5  = 19'b0000111010110011001;
parameter A5   = 19'b0000110111101110010;
parameter As5  = 19'b0000110101001001101;
parameter B5   = 19'b0000110011110111010;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input CLOCK_50;
input [3:0] KEY;
input [9:0] SW;
input [35:0] GPIO_0; // using GPIO_0[11:0] for notes and GPIO_0[12] for octave selection
input[35:0] GPIO_1;
input AUD_ADCDAT;

// Bidirectionals
inout AUD_BCLK;
inout AUD_ADCLRCK;
inout AUD_DACLRCK;
inout FPGA_I2C_SDAT;

// Outputs
output AUD_XCK;
output AUD_DACDAT;
output FPGA_I2C_SCLK;
output [6:0] HEX0, HEX1, HEX2;
output [9:0] LEDR;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Switch mapping:
// SW[9:8] - octave selection 
// SW[7]   - pitch bend enable
// SW[6:5] - wave select
// SW[4]   - filter enable 
// SW[3:1] - filter coefficient
// SW[0] = 0: Manual playing mode (GPIO input)
// SW[0] = 1: Song playback mode

//KEY[1] Triggers the Song Playback

// Internal signals for filtered audio
wire [31:0] sound;
wire [31:0] filtered_sound;

// Internal Wires
wire audio_in_available;
wire [31:0] left_channel_audio_in;
wire [31:0] right_channel_audio_in;
wire read_audio_in;

wire audio_out_allowed;
wire [31:0] left_channel_audio_out;
wire [31:0] right_channel_audio_out;
wire write_audio_out;

// Internal Registers
reg [18:0] delay_cnt;
wire [18:0] delay;
reg snd;

//UART data receive
wire [7:0] uart_rx_data;

// Internal signals for song player
wire [18:0] song_note;   // Output from song player
wire [11:0] note_select; // Wire to connect to total_tone_generator
wire [11:0] final_note_select;
wire [11:0] gpio_notes = GPIO_0[11:0];


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
assign read_audio_in = audio_in_available & audio_out_allowed;
assign left_channel_audio_out = left_channel_audio_in + sound;
assign right_channel_audio_out = right_channel_audio_in + sound;
assign write_audio_out = audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
//song_player song_inst(.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW), .out_note(out_note));
//total_tone_generator tone_gen (.GPIO_0({12'B0, current_note}), .octave_sel(SW[9:8]), .total_sound(left_channel_audio_out), .CLOCK_50(CLOCK_50));

// Song player instantiation
song_player song_inst (
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),          // KEY[1] will trigger the song
    .SW(SW),
    .out_note(song_note)
);

// Note decoder to convert song_note to GPIO format
note_decoder decoder_inst (
    .note_freq(song_note),
    .note_select(note_select)
);

// Multiplexer using SW[0] for selection
assign final_note_select = SW[0] ? note_select : gpio_notes;

// Modified total_tone_generator instantiation - other connections remain the same
total_tone_generator T1 (
    .GPIO_0(final_note_select),  // Now connected to multiplexer output
    .octave_sel(SW[9:8]),
    .wave_select(SW[6:5]),
    .total_sound(sound),
    .CLOCK_50(CLOCK_50),
    .uart_data(uart_rx_data),
    .SW(SW[7])
);

// total_tone_generator T1 (GPIO_0[11:0],SW[9:8],SW[6:5],sound,CLOCK_50, uart_rx_data, SW[7]);

//UART connection from the arduino and GY521 => provide data from GY521 in a byte
uart_receiver uart_rx_inst (
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .SW(SW),
    .LEDR(LEDR),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .GPIO_1(GPIO_1),
    .output_data(uart_rx_data)
);

//filtering
configurable_filter #(
    .DATA_WIDTH(32),
    .FILTER_ORDER(4)
) audio_filter (
    .clk(CLOCK_50),
    .reset(~KEY[0]),
    .enable(SW[4]),
    .coefficient_select(SW[3:1]),
    .audio_in(sound),
    .audio_out(filtered_sound)
);

// Instantiate the audio controller given
Audio_Controller Audio_Controller (
    // Inputs
    .CLOCK_50(CLOCK_50),
    .reset(~KEY[0]),
    .clear_audio_in_memory(),
    .read_audio_in(read_audio_in),
    .clear_audio_out_memory(),
    .left_channel_audio_out(left_channel_audio_in + filtered_sound),
    .right_channel_audio_out(left_channel_audio_in + filtered_sound),
    .write_audio_out(write_audio_out),
    .AUD_ADCDAT(AUD_ADCDAT),

    // Bidirectionals
    .AUD_BCLK(AUD_BCLK),
    .AUD_ADCLRCK(AUD_ADCLRCK),
    .AUD_DACLRCK(AUD_DACLRCK),

    // Outputs
    .audio_in_available(audio_in_available),
    .left_channel_audio_in(left_channel_audio_in),
    .right_channel_audio_in(right_channel_audio_in),
    .audio_out_allowed(audio_out_allowed),
    .AUD_XCK(AUD_XCK),
    .AUD_DACDAT(AUD_DACDAT)
);

avconf #(.USE_MIC_INPUT(1)) avc (
    .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
    .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
    .CLOCK_50(CLOCK_50),
    .reset(~KEY[0])
);

endmodule

//module note_selector (
//    input [1:0] octave_selector,
//    input [11:0] sel,
//    output reg [18:0] out
//);
//
//
//    // This module assumes ONLY one switch is on at a time
//    always @(*) begin
//        if (octave_selector[0]) begin
//            case (sel)
//                12'b000000000001: out = C5;
//                12'b000000000010: out = Cs5;
//                12'b000000000100: out = D5;
//                12'b000000001000: out = Ds5;
//                12'b000000010000: out = E5;
//                12'b000000100000: out = F5;
//                12'b000001000000: out = Fs5;
//                12'b000010000000: out = G5;
//                12'b000100000000: out = Gs5;
//                12'b001000000000: out = A5;
//                12'b010000000000: out = As5;
//                12'b100000000000: out = B5;
//                default: out = 19'b0;
//            endcase
//        end 
//		  else if(octave_selector[1]) begin
//            case (sel)
//                12'b000000000001: out = C4;
//                12'b000000000010: out = Cs4;
//                12'b000000000100: out = D4;
//                12'b000000001000: out = Ds4;
//                12'b000000010000: out = E4;
//                12'b000000100000: out = F4;
//                12'b000001000000: out = Fs4;
//                12'b000010000000: out = G4;
//                12'b000100000000: out = Gs4;
//                12'b001000000000: out = A4;
//                12'b010000000000: out = As4;
//                12'b100000000000: out = B4;
//                default: out = 19'b0;
//            endcase
//        end
//    end
//endmodule
