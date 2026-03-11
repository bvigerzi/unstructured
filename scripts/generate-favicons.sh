#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="$SCRIPT_DIR/../public/favicon.svg"
OUTPUT_DIR="$SCRIPT_DIR/../public"

# PNG exports
inkscape "$INPUT" --export-type=png --export-filename="$OUTPUT_DIR/favicon-32x32.png" -w 32 -h 32
inkscape "$INPUT" --export-type=png --export-filename="$OUTPUT_DIR/favicon-16x16.png" -w 16 -h 16
inkscape "$INPUT" --export-type=png --export-filename="$OUTPUT_DIR/apple-touch-icon.png" -w 180 -h 180

# ICO export (requires ImageMagick)
inkscape "$INPUT" --export-type=png --export-filename="$OUTPUT_DIR/favicon-tmp-32.png" -w 32 -h 32
convert "$OUTPUT_DIR/favicon-tmp-32.png" "$OUTPUT_DIR/favicon.ico"
rm "$OUTPUT_DIR/favicon-tmp-32.png"
