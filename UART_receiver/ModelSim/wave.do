onerror {resume}
quietly WaveActivateNextPane {} 0

# Clock and Control Signals
add wave -noupdate -divider {Clock and Control}
add wave -noupdate -format Logic -radix binary /uart_receiver_tb/CLOCK_50
add wave -noupdate -format Logic -radix binary /uart_receiver_tb/KEY
add wave -noupdate -format Logic -radix binary /uart_receiver_tb/GPIO_1[0]

# UART Internal Signals
add wave -noupdate -divider {UART Internal}
add wave -noupdate -format Logic /uart_receiver_tb/uut/rx_data
add wave -noupdate -format Logic /uart_receiver_tb/uut/rx_falling_edge
add wave -noupdate -format Literal -radix unsigned /uart_receiver_tb/uut/state
add wave -noupdate -format Literal -radix unsigned /uart_receiver_tb/uut/clk_count
add wave -noupdate -format Literal -radix unsigned /uart_receiver_tb/uut/bit_index
add wave -noupdate -format Literal -radix hexadecimal /uart_receiver_tb/uut/rx_byte

# Output Signals
add wave -noupdate -divider {Outputs}
add wave -noupdate -format Literal -radix hexadecimal /uart_receiver_tb/LEDR
add wave -noupdate -format Literal -radix hexadecimal /uart_receiver_tb/output_data
add wave -noupdate -format Literal -radix hexadecimal /uart_receiver_tb/HEX0
add wave -noupdate -format Literal -radix hexadecimal /uart_receiver_tb/HEX1
add wave -noupdate -format Literal -radix hexadecimal /uart_receiver_tb/HEX2

# Configuration
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1050 us}