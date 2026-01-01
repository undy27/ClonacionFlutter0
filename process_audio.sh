#!/bin/bash

# Script to remove silence from audio file for seamless looping
# Requires ffmpeg to be installed

INPUT_FILE="src/assets/musica/M.2.wav"
OUTPUT_FILE="src/assets/musica/M.2.processed.wav"
BACKUP_FILE="src/assets/musica/M.2.original.wav"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed"
    echo "Install with: brew install ffmpeg"
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: $INPUT_FILE not found"
    exit 1
fi

echo "Processing $INPUT_FILE..."
echo "Removing silence from beginning and end..."

# Backup original file
cp "$INPUT_FILE" "$BACKUP_FILE"
echo "Original file backed up to $BACKUP_FILE"

# Remove silence from beginning and end
# silencedetect finds silence, silenceremove removes it
# -af: audio filter
# silenceremove=start_periods=1:start_duration=0.1:start_threshold=-50dB:stop_periods=-1:stop_duration=0.1:stop_threshold=-50dB
ffmpeg -i "$INPUT_FILE" \
    -af "silenceremove=start_periods=1:start_duration=0.1:start_threshold=-50dB:stop_periods=-1:stop_duration=0.1:stop_threshold=-50dB" \
    -y "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Success! Processed file saved to $OUTPUT_FILE"
    echo ""
    echo "To use the processed file:"
    echo "  mv '$OUTPUT_FILE' '$INPUT_FILE'"
    echo ""
    echo "To restore original:"
    echo "  mv '$BACKUP_FILE' '$INPUT_FILE'"
else
    echo "Error processing file"
    exit 1
fi
