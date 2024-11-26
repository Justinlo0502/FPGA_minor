onerror {resume}
quietly WaveActivateNextPane {} 0

# Clock and Control Signals
add wave -noupdate -divider {Clock and Control}
add wave -noupdate /testbench/CLOCK_50
add wave -noupdate /testbench/SW
add wave -noupdate /testbench/GPIO_0
add wave -noupdate /testbench/octave_sel
add wave -noupdate /testbench/uart_data

# Internal Signals
add wave -noupdate -divider {Internal Signals}
add wave -noupdate /testbench/uut/delay_cnt[0]
add wave -noupdate /testbench/uut/delay_prime[0]
add wave -noupdate /testbench/uut/snd[0]
add wave -noupdate /testbench/uut/sound[0]

add wave -noupdate /testbench/uut/delay_cnt[4]
add wave -noupdate /testbench/uut/delay_prime[4]
add wave -noupdate /testbench/uut/snd[4]
add wave -noupdate /testbench/uut/sound[4]

add wave -noupdate /testbench/uut/delay_cnt[7]
add wave -noupdate /testbench/uut/delay_prime[7]
add wave -noupdate /testbench/uut/snd[7]
add wave -noupdate /testbench/uut/sound[7]

# Sound Output
add wave -noupdate -divider {Sound Output}
add wave -noupdate /testbench/total_sound

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
WaveRestoreZoom {0 ps} {5000 us}