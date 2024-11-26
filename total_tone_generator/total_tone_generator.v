module total_tone_generator(
    input [11:0] GPIO_0,
    input [1:0] octave_sel,
    input [1:0] wave_select,
    output [31:0] total_sound,
    input CLOCK_50,
    input [7:0] uart_data,
    input SW
);

    /*****************************************************************************
     *                           Parameter Declarations                          *
     *****************************************************************************/
    // Define the 19-bit delays for each note
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

    // Internal Registers and Wires
    reg [18:0] delay_cnt[0:11];
    wire [18:0] delay[0:11];
    wire [18:0] delay_prime[0:11];
    reg snd[0:11];
    wire signed [31:0] note_sounds[0:11]; //output for waveform generator

    // 12 instances of individual_note_selector
    individual_note_selector U1  (GPIO_0[0],  octave_sel, C4,  C5,  delay[0]);
    individual_note_selector U2  (GPIO_0[1],  octave_sel, Cs4, Cs5, delay[1]);
    individual_note_selector U3  (GPIO_0[2],  octave_sel, D4,  D5,  delay[2]);
    individual_note_selector U4  (GPIO_0[3],  octave_sel, Ds4, Ds5, delay[3]);
    individual_note_selector U5  (GPIO_0[4],  octave_sel, E4,  E5,  delay[4]);
    individual_note_selector U6  (GPIO_0[5],  octave_sel, F4,  F5,  delay[5]);
    individual_note_selector U7  (GPIO_0[6],  octave_sel, Fs4, Fs5, delay[6]);
    individual_note_selector U8  (GPIO_0[7],  octave_sel, G4,  G5,  delay[7]);
    individual_note_selector U9  (GPIO_0[8],  octave_sel, Gs4, Gs5, delay[8]);
    individual_note_selector U10 (GPIO_0[9],  octave_sel, A4,  A5,  delay[9]);
    individual_note_selector U11 (GPIO_0[10], octave_sel, As4, As5, delay[10]);
    individual_note_selector U12 (GPIO_0[11], octave_sel, B4,  B5,  delay[11]);

    // // Sequential logic for delay_prime
    // genvar z;
    // generate
    //     for (z = 0; z < 12; z = z + 1) begin : delay_adjustment
    //         //apply PITCH BENDING EFFECT
    //         always @(posedge CLOCK_50) begin
    //             if (SW) begin
    //                 delay_prime[z] <= delay[z] * (200 - uart_data) / 100;
    //             end else begin
    //                 delay_prime[z] <= delay[z];
    //             end
    //         end

    //         //apply WAVEFORM TRANSFORMATION EFFECT
    //         waveform_generator wave_gen (
    //             .CLOCK_50(CLOCK_50),
    //             .note_period(delay_prime[z]),  // Use pitch-bent period
    //             .wave_select(wave_select),     // Wave shape selection
    //             .note_enable(GPIO_0[z]),       // Note on/off from GPIO
    //             .wave_out(note_sounds[z])      // Output for this note
    //         );
    //     end
    // endgenerate
    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : wave_gen_first_half
            // First 6 notes
            assign delay_prime[i] = SW ? (delay[i] * (200 - uart_data) / 100) : delay[i];
            
            waveform_generator wave_gen (
                .CLOCK_50(CLOCK_50),
                .note_period(delay_prime[i]),
                .wave_select(wave_select),
                .note_enable(GPIO_0[i]),
                .wave_out(note_sounds[i])
            );
        end
    endgenerate

    // Second set of generators
    generate
        for (i = 6; i < 12; i = i + 1) begin : wave_gen_second_half
            assign delay_prime[i] = SW ? (delay[i] * (200 - uart_data) / 100) : delay[i];
            
            waveform_generator wave_gen (
                .CLOCK_50(CLOCK_50),
                .note_period(delay_prime[i]),
                .wave_select(wave_select),
                .note_enable(GPIO_0[i]),
                .wave_out(note_sounds[i])
            );
        end
    endgenerate

    // DELETED CAUSE NEW LOGIC HANDLED IN WAVEFORM_GENERATOR
    // Generate block for delay counters and sound generation
    // genvar i;
    // generate
    //     for (i = 0; i < 12; i = i + 1) begin : delay_instances
    //         always @(posedge CLOCK_50) begin
    //             if (delay_cnt[i] == delay_prime[i]) begin
    //                 delay_cnt[i] <= 0;
    //                 snd[i] <= !snd[i];
    //             end else begin
    //                 delay_cnt[i] <= delay_cnt[i] + 1;
    //             end
    //         end
    //     end
    // endgenerate

    // Define sound output array
    wire signed [31:0] sound [0:11];

    // Generate sound output assignments
    genvar j;
    generate
        for (j = 0; j < 12; j = j + 1) begin : sound_gen
            assign sound[j] = (GPIO_0[j] == 0) ? 0 : 
                            snd[j] ? 32'd10000000 : -32'd10000000;
        end
    endgenerate

    // Sum all sounds to produce total_sound
    reg [31:0] total_sound_reg;
    integer k;
    
    always @(*) begin
        total_sound_reg = 0;
        for (k = 0; k < 12; k = k + 1) begin
            total_sound_reg = total_sound_reg + note_sounds[k];
        end
    end
    
    assign total_sound = total_sound_reg;

endmodule