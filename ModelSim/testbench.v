`timescale 1ns / 1ps

module testbench ( );

    parameter CLOCK_PERIOD = 10;

    reg [9:0] SW;
    reg [3:0] KEY;
    reg CLOCK_50;
    wire [18:0] out_note;

    initial begin
        CLOCK_50 <= 1'b0;
    end 

    always @ (*)
    begin : Clock_Generator
        #((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
    end
    
    // Reset sequence
    initial begin
        KEY[0] <= 1'b0;  // Assert reset
        #100 KEY[0] <= 1'b1;  // Release reset after 100ns
    end

    // Test stimulus for song player
    initial begin
        // Initialize
        SW <= 10'b0; 
        KEY[1] <= 1'b1;  // Start with KEY[1] released
        
        // Wait for reset to complete
        #200;
        
        // Press KEY[1] to start song
        KEY[1] <= 1'b0;
        #100;
        KEY[1] <= 1'b1;
        
        // Let song play for a while
        #5000;
        
        // Press KEY[1] again to stop song
        KEY[1] <= 1'b0;
        #100;
        KEY[1] <= 1'b1;
        
        // Wait a bit
        #1000;
        
        // Press KEY[1] again to restart song
        KEY[1] <= 1'b0;
        #100;
        KEY[1] <= 1'b1;
        
        // Let it play some more
        #5000;
    end
    
    song_player U1 (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .out_note(out_note)
    );

endmodule