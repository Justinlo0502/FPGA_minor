module uart_receiver(
    input              CLOCK_50,
    input      [3:0]   KEY,
    input      [9:0]   SW,
    output reg [9:0]   LEDR,     
    output reg [6:0]   HEX0,      
    output reg [6:0]   HEX1,      
    output reg [6:0]   HEX2,      
    inout     [35:0]   GPIO_1,
    output [7:0] output_data
);

    wire reset_n = KEY[0];
    wire rxd;
    assign rxd = GPIO_1[0] ? 1'b1 : 1'b0;

    reg [2:0] rx_sync;
    reg rx_data;
    reg [7:0] buffer_reg;
    
    // add falling edge detection to prevent false start
    // added because it was reading random shit like 231
    //Basically synchronizes the reading process to when (START_BIT) begins
    reg rx_data_prev;
    wire rx_falling_edge;
    
    // Seven-segment patterns
    reg [6:0] seg7_patterns [9:0];
    initial begin
        seg7_patterns[0] = 7'b1000000;
        seg7_patterns[1] = 7'b1111001;
        seg7_patterns[2] = 7'b0100100;
        seg7_patterns[3] = 7'b0110000;
        seg7_patterns[4] = 7'b0011001;
        seg7_patterns[5] = 7'b0010010;
        seg7_patterns[6] = 7'b0000010;
        seg7_patterns[7] = 7'b1111000;
        seg7_patterns[8] = 7'b0000000;
        seg7_patterns[9] = 7'b0010000;
    end
    
    always @(posedge CLOCK_50) begin
        rx_sync <= {rx_sync[1:0], rxd};
        rx_data <= rx_sync[2];
        rx_data_prev <= rx_data;
    end
    
    assign rx_falling_edge = rx_data_prev & ~rx_data;

    parameter IDLE = 0, START_BIT = 1, DATA_BITS = 2, STOP_BIT = 3;
    parameter CLOCK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    parameter CLKS_PER_BIT = CLOCK_FREQ/BAUD_RATE;
    parameter CLKS_PER_HALF_BIT = CLKS_PER_BIT/2;

    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_byte;
    reg [2:0] state;
    reg data_valid;
    reg [7:0] prev_rx_byte;

    //FSM code
    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_byte <= 0;
            buffer_reg <= 0;
            data_valid <= 0;
            prev_rx_byte <= 0;
            LEDR <= 0;
            HEX0 <= 7'b1111111;
            HEX1 <= 7'b1111111;
            HEX2 <= 7'b1111111;
        end else begin
            case (state)
                IDLE: begin
                    clk_count <= 0;
                    bit_index <= 0;
                    data_valid <= 0;
                    // Only check for the falling_edge because the START_BIT is logic low and END_BIT it logic high
                    if (rx_falling_edge) begin
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    if (clk_count < CLKS_PER_HALF_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        if (rx_data == 0) begin
                            clk_count <= 0;
                            state <= DATA_BITS;
                        end else
                            state <= IDLE;
                    end
                end

                DATA_BITS: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        rx_byte[bit_index] <= rx_data;
                        bit_index <= bit_index + 1;

                        if (bit_index == 7) begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        state <= IDLE;
                        if (rx_data == 1) begin
                            // Data validation for 0-100 range
									 // Change here and Cpp file for sensitivity change
                            if (rx_byte <= 200) begin
                                buffer_reg <= rx_byte;
                                LEDR[7:0] <= rx_byte;
                                HEX0 <= seg7_patterns[rx_byte % 10];
                                HEX1 <= seg7_patterns[(rx_byte / 10) % 10];
                                HEX2 <= seg7_patterns[rx_byte / 100];
                                prev_rx_byte <= rx_byte;
                                data_valid <= 1;
                            end
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    assign output_data = rx_byte;

endmodule