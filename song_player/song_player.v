module song_player (
    input CLOCK_50,  
    input [9:0] SW,
    input [3:0] KEY,         // KEY[1] triggers the song
    output reg [18:0] out_note // Output note frequency
);

    // Define the note frequencies
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

    parameter Rest = 19'b0000000000000000000;

    // Timing parameters for 100 BPM
    // At 100 BPM, one quarter note = 600ms = 30,000,000 clock cycles at 50MHz
    parameter QUARTER_NOTE = 30_000_000;  // Quarter note duration
    parameter EIGHTH_NOTE = QUARTER_NOTE/2;
    parameter HALF_NOTE = QUARTER_NOTE*2;
    parameter WHOLE_NOTE = QUARTER_NOTE*4;
    parameter SIXTEENTH_NOTE = QUARTER_NOTE/4;

    // Song data
    reg [18:0] song_notes[0:31]; // Note frequencies
    reg [31:0] note_durations[0:31]; // Actual clock cycles for duration
    integer note_index;             // Current note index
    reg [31:0] note_timer;  
    integer i;      

    // Initialize the song (Super Mario Bros theme)
    initial begin
        // Main melody
        song_notes[0] = E5;  note_durations[0] = QUARTER_NOTE;  
        song_notes[1] = Rest; note_durations[1] = SIXTEENTH_NOTE;  
        song_notes[2] = E5;  note_durations[2] = QUARTER_NOTE;  
        song_notes[3] = Rest;  note_durations[3] = SIXTEENTH_NOTE;
        song_notes[4] = E5;  note_durations[4] = QUARTER_NOTE;
        song_notes[5] = Rest;  note_durations[5] = QUARTER_NOTE;  
        song_notes[6] = C5; note_durations[6] = QUARTER_NOTE;
        song_notes[7] = E5;  note_durations[7] = QUARTER_NOTE;
        song_notes[8] = G5;  note_durations[8] = HALF_NOTE;  
        song_notes[9] = Rest;  note_durations[9] = QUARTER_NOTE;  
        song_notes[10] = G4; note_durations[10] = QUARTER_NOTE;
        song_notes[11] = Rest; note_durations[11] = QUARTER_NOTE;

        // Second part
        song_notes[12] = C5; note_durations[12] = QUARTER_NOTE;
        song_notes[13] = Rest; note_durations[13] = EIGHTH_NOTE;
        song_notes[14] = G4; note_durations[14] = QUARTER_NOTE;
        song_notes[15] = Rest; note_durations[15] = EIGHTH_NOTE;
        song_notes[16] = E4; note_durations[16] = QUARTER_NOTE;
        song_notes[17] = Rest; note_durations[17] = EIGHTH_NOTE;
        song_notes[18] = A4; note_durations[18] = QUARTER_NOTE;
        song_notes[19] = Rest; note_durations[19] = SIXTEENTH_NOTE;
        song_notes[20] = B4; note_durations[20] = QUARTER_NOTE;
        song_notes[21] = Rest; note_durations[21] = SIXTEENTH_NOTE;
        song_notes[22] = As4; note_durations[22] = QUARTER_NOTE;
        song_notes[23] = A4; note_durations[23] = QUARTER_NOTE;

        song_notes[24] = G4; note_durations[24] = QUARTER_NOTE * 3/2;
        song_notes[25] = E5; note_durations[25] = QUARTER_NOTE * 3/2;
        song_notes[26] = G5; note_durations[26] = QUARTER_NOTE * 3/2;
        song_notes[27] = A5; note_durations[27] = QUARTER_NOTE;

        // Fill remaining slots with rest
        for (i = 28; i < 32; i = i + 1) begin
            song_notes[i] = Rest;
            note_durations[i] = QUARTER_NOTE;
        end
    end

    // State for tracking if the song is playing
    reg playing;
    reg prev_key;

    // Playback Logic
    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin  // Reset button pressed
            note_index <= 0;
            note_timer <= 0;
            out_note <= Rest;
            playing <= 0;
            prev_key <= 1;
        end else begin
            // Edge detection for KEY[1]
            if (prev_key && !KEY[1]) begin  // Detect falling edge (button press)
                playing <= !playing;         // Toggle playing state
            end
            prev_key <= KEY[1];

            if (playing) begin
                if (note_timer == 0) begin
                    // Move to the next note
                    out_note <= song_notes[note_index];
                    note_timer <= note_durations[note_index];
                    
                    // Move to next note
                    if (note_index >= 31)
                        note_index <= 0;
                    else
                        note_index <= note_index + 1;
                end else begin
                    // Decrement the note timer
                    note_timer <= note_timer - 1;
                end
            end else begin
                // When not playing, reset to beginning and silence
                out_note <= Rest;
                note_timer <= 0;
                note_index <= 0;
            end
        end
    end
endmodule