`timescale 1ns / 1ps

module uart_receiver_tb();

    // Parameters
    parameter CLOCK_PERIOD = 20; // 50MHz clock
    parameter BAUD_PERIOD = 104167; // For 9600 baud rate (1/9600 seconds)

    // Test bench signals
    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2;
    wire [35:0] GPIO_1;
    wire [7:0] output_data;

    // Test data
    reg [7:0] test_data [0:2];
    reg GPIO_1_reg;
    assign GPIO_1[0] = GPIO_1_reg;

    // Instantiate the UART receiver
    uart_receiver uut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .GPIO_1(GPIO_1),
        .output_data(output_data)
    );

    // Clock generation
    initial begin
        CLOCK_50 = 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
    end

    // Task to send one byte of UART data
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit (low)
            GPIO_1_reg = 0;
            #BAUD_PERIOD;

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                GPIO_1_reg = data[i];
                #BAUD_PERIOD;
            end

            // Stop bit (high)
            GPIO_1_reg = 1;
            #BAUD_PERIOD;
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize test data
        test_data[0] = 8'h55; // 01010101
        test_data[1] = 8'hAA; // 10101010
        test_data[2] = 8'h3C; // 00111100

        // Initialize signals
        KEY = 4'hF;  // Active low reset
        SW = 10'h0;
        GPIO_1_reg = 1;

        // Reset the system
        #100;
        KEY[0] = 0;  // Assert reset
        #100;
        KEY[0] = 1;  // Release reset
        #100;

        // Send test data
        send_uart_byte(test_data[0]);
        #(BAUD_PERIOD*2);

        send_uart_byte(test_data[1]);
        #(BAUD_PERIOD*2);

        send_uart_byte(test_data[2]);
        #(BAUD_PERIOD*2);

        // End simulation
        #1000;
        $finish;
    end

    // Monitor output
    always @(posedge CLOCK_50) begin
        if (LEDR[7:0] != 8'h00) begin
            $display("Time=%0t Received data: %h", $time, LEDR[7:0]);
        end
    end

endmodule