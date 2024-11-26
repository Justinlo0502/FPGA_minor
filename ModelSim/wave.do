onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Inputs}
add wave -noupdate -label CLOCK_50 -radix binary /song_player_testbench/CLOCK_50
add wave -noupdate -label KEY -radix binary -expand /song_player_testbench/KEY
add wave -noupdate -label SW -radix binary -expand /song_player_testbench/SW

add wave -noupdate -divider {Outputs}
add wave -noupdate -label out_note -radix hexadecimal /song_player_testbench/out_note

add wave -noupdate -divider {Internal Signals}
add wave -noupdate -label note_index -radix decimal /song_player_testbench/DUT/note_index
add wave -noupdate -label note_timer -radix decimal /song_player_testbench/DUT/note_timer
add wave -noupdate -label playing -radix binary /song_player_testbench/DUT/playing
add wave -noupdate -label prev_key -radix binary /song_player_testbench/DUT/prev_key

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {10000 ns}