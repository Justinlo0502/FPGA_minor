# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../song_player/song_player.v
# compile the Verilog code of the testbench
vlog testbench.v
# start the Simulator
vsim work.song_player_testbench -Lf 220model -Lf altera_mf_ver -Lf verilog
# show waveforms specified in wave.do
do wave.do
# advance the simulation for enough time to hear multiple notes at proper tempo
run 10000ms