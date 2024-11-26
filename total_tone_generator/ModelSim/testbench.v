`timescale 1ns / 1ps

module testbench();
    // Parameters
    parameter CLOCK_PERIOD = 20; // 50MHz clock

    // Test bench signals
    reg [11:0] GPIO_0;
    reg [1:0] octave_sel;
    wire [31:0] total_sound;
    reg CLOCK_50;
    reg [7:0] uart_data;
    reg SW;

    // Instantiate the tone generator
    total_tone_generator uut (
        .GPIO_0(GPIO_0),
        .octave_sel(octave_sel),
        .total_sound(total_sound),
        .CLOCK_50(CLOCK_50),
        .uart_data(uart_data),
        .SW(SW)
    );

    // Clock generation
    initial begin
        CLOCK_50 = 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
    end

    // Test stimulus
    initial begin
        // Initialize signals
        GPIO_0 = 12'h000;
        octave_sel = 2'b00;
        uart_data = 8'd100;
        SW = 1'b0;

        // Short stabilization
        #200;  // 200ns stabilization
        
        // C Major chord (C-E-G)
        $display("Testing C Major chord at %0t ns", $time);
        GPIO_0 = 12'b000000010001;  
        octave_sel = 2'b00;         
        #1000;  // 1us per chord

        // F Major chord (F-A-C)
        $display("Testing F Major chord at %0t ns", $time);
        GPIO_0 = 12'b000100000100;  
        #1000;  // 1us per chord

        // G Major chord (G-B-D)
        $display("Testing G Major chord at %0t ns", $time);
        GPIO_0 = 12'b010000010000;  
        #1000;  // 1us per chord

        // End simulation
        $display("Ending simulation at %0t ns", $time);
        #200;
        $finish;
    end

    // Monitor output every 200ns
    always @(posedge CLOCK_50) begin
        if ($time % 200 == 0) begin
            $display("Time=%0t ns, Total Sound=%0d", $time, total_sound);
        end
    end

endmodule