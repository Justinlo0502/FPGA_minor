# Stop any existing simulation
quit -sim

# Create the default "work" library
vlib work

# Compile the source files
vlog ../uart_receiver.v
vlog testbench.v

# Start the simulator
vsim work.uart_receiver_tb

# Load the wave configuration
do wave.do

# Run the simulation for 2ms (adjust as needed)
run 2000us

# Zoom full
wave zoom full