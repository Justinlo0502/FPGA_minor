# FPGA_minor

# FPGA-Based Digital Music Synthesizer with Interactive Controls

## Project Overview

This project implements a fully functional digital music synthesizer on an FPGA platform, featuring polyphonic sound generation, interactive controls, and multiple sound shaping capabilities. The synthesizer includes both manual play mode and an automatic song player feature, making it suitable for both live performance and automated music playback.

## Key Features

### 1. Sound Generation

- 12-note polyphonic capability (C through B)
- Two full octaves of range (C4-B4 and C5-B5)
- Four distinct waveform shapes:
  - Standard Square Wave (50% duty cycle)
  - Quarter Square Wave (25% duty cycle)
  - Low Volume Square Wave
  - Very Short Pulse Wave

### 2. Interactive Controls

- **Manual Play Mode**:
  - 12 GPIO inputs for individual note triggering
  - Real-time octave switching
  - Instantaneous wave shape selection
- **Song Player Mode**:
  - Pre-programmed song playback (Super Mario Bros theme)
  - Tempo-accurate note sequencing (100 BPM)
  - Play/pause functionality

### 3. Sound Modification Features

- **Pitch Bending**:
  - Real-time frequency modification
  - UART-based control input
  - Smooth pitch transitions
- **Waveform Selection**:
  - On-the-fly wave shape switching
  - Multiple timbre options
  - Volume variation through wave shape

## Hardware Implementation

### Input Devices

- Push buttons for control functions:
  - KEY[0]: System reset
  - KEY[1]: Song player control
- Switches for sound parameters:
  - SW[9:8]: Octave selection
  - SW[7]: Pitch bend enable
  - SW[6:5]: Waveform shape selection
- GPIO pins for note input
- UART interface for external control data

### Output System

- Audio output through DE2 board's audio codec
- LED indicators for system status
- Real-time audio signal processing
- 32-bit audio sample resolution

## System Architecture

### Core Modules

1. **Total Tone Generator**:

   - Central sound generation unit
   - Polyphonic note handling
   - Waveform synthesis

2. **Individual Note Selectors**:

   - Frequency calculation
   - Octave management
   - Note period generation

3. **Waveform Generators**:

   - Wave shape implementation
   - Amplitude control
   - Signal generation

4. **Song Player**:
   - Note sequencing
   - Tempo management
   - Playback control

### Signal Processing

- Real-time audio sample generation
- Polyphonic signal mixing
- Dynamic frequency modification
- Amplitude scaling and control

## Technical Specifications

- Clock Frequency: 50MHz
- Audio Sample Resolution: 32-bit
- Polyphony: 12 notes
- Octave Range: 2 octaves (C4-B5)
- Tempo: 100 BPM (song player)
- Note Period Resolution: 19-bit

## Educational Value

The project demonstrates several important concepts in digital systems:

- Digital audio synthesis
- Real-time signal processing
- State machine implementation
- Clock domain management
- System integration
- User interface design

## Potential Applications

- Music education
- Live performance
- Sound synthesis demonstration
- Digital audio experimentation
- FPGA learning platform

## Future Enhancement Possibilities

- Additional waveform types
- More octave ranges
- Effect processors (reverb, delay)
- MIDI interface integration
- LCD display for parameters
- Memory for multiple songs
- Advanced envelope control

This project successfully combines digital audio synthesis, real-time control, and user interaction to create a versatile and educational musical instrument platform.
