# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work

# compile the Verilog source code
vlog ../total_tone_generator.v
vlog ../individual_note_selector.v  
vlog testbench.v

# start the Simulator
vsim -t 1ps -L rtl_work -L work -voptargs="+acc" work.testbench

# Load the wave configuration
do wave.do

# Set radix for viewing signals
radix -hexadecimal
radix signal testbench/uart_data decimal
radix signal testbench/total_sound decimal

# Run the simulation
run 4us  # Total time needed: ~3.4us

# Zoom full
wave zoom full