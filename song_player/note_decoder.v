module note_decoder (
    input [18:0] note_freq,
    output reg [11:0] note_select
);

    // Parameters for note frequencies (you already have these defined in your top module)
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
    parameter Rest = 19'b0000000000000000000;

    always @(*) begin
        case(note_freq)
            C4:  note_select = 12'b000000000001;
            Cs4: note_select = 12'b000000000010;
            D4:  note_select = 12'b000000000100;
            Ds4: note_select = 12'b000000001000;
            E4:  note_select = 12'b000000010000;
            F4:  note_select = 12'b000000100000;
            Fs4: note_select = 12'b000001000000;
            G4:  note_select = 12'b000010000000;
            Gs4: note_select = 12'b000100000000;
            A4:  note_select = 12'b001000000000;
            As4: note_select = 12'b010000000000;
            B4:  note_select = 12'b100000000000;
            Rest: note_select = 12'b000000000000;
            default: note_select = 12'b000000000000;
        endcase
    end
endmodule