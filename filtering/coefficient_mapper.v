/*
This module basically maps the 3 bit select input throughout ther 8 bit coefficient to spread out the values that 
can be chose 
*/
module coefficient_mapper(
    input [2:0] coefficient_select,     // 3-bit input
    output reg [7:0] coefficient        // 8-bit mapped output
);

    // Maps 3 bits to 8 spread-out values across 0-255 range
    always @(*) begin
        case(coefficient_select)
            3'b000: coefficient = 8'd0;    // 0%   filtering - pure input
            3'b001: coefficient = 8'd36;   // 14%  filtering
            3'b010: coefficient = 8'd73;   // 29%  filtering
            3'b011: coefficient = 8'd109;  // 43%  filtering
            3'b100: coefficient = 8'd146;  // 57%  filtering
            3'b101: coefficient = 8'd182;  // 71%  filtering
            3'b110: coefficient = 8'd219;  // 86%  filtering
            3'b111: coefficient = 8'd255;  // 100% filtering - maximum smoothing
            default: coefficient = 8'd0;
        endcase
    end
endmodule