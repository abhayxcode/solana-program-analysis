#!/bin/bash
# Disassemble a Solana program binary
#
# Usage: ./disassemble.sh <program-name>
# Example: ./disassemble.sh dflow

set -e

PROGRAM_NAME="${1:?Error: Program name required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROGRAM_DIR="$ROOT_DIR/programs/$PROGRAM_NAME"
OUTPUT_DIR="$PROGRAM_DIR/disassembly"

# Check if program binary exists
if [ ! -f "$PROGRAM_DIR/program.so" ]; then
    echo "Error: Program binary not found at $PROGRAM_DIR/program.so"
    echo "Run ./download.sh first"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Find LLVM objdump
OBJDUMP=""
if command -v llvm-objdump &> /dev/null; then
    OBJDUMP="llvm-objdump"
elif [ -f "/opt/homebrew/opt/llvm/bin/llvm-objdump" ]; then
    OBJDUMP="/opt/homebrew/opt/llvm/bin/llvm-objdump"
elif [ -f "/usr/local/opt/llvm/bin/llvm-objdump" ]; then
    OBJDUMP="/usr/local/opt/llvm/bin/llvm-objdump"
else
    echo "Error: llvm-objdump not found"
    echo "Install LLVM:"
    echo "  macOS: brew install llvm"
    echo "  Ubuntu: apt install llvm"
    exit 1
fi

echo "Disassembling $PROGRAM_NAME..."
echo "Using: $OBJDUMP"

# Full disassembly
echo "Generating full disassembly..."
$OBJDUMP -d "$PROGRAM_DIR/program.so" > "$OUTPUT_DIR/program.asm" 2>&1

# Extract sections
echo "Extracting section headers..."
$OBJDUMP -h "$PROGRAM_DIR/program.so" > "$OUTPUT_DIR/sections.txt" 2>&1 || true

# Extract symbols (if not stripped)
echo "Extracting symbols..."
$OBJDUMP -t "$PROGRAM_DIR/program.so" > "$OUTPUT_DIR/symbols.txt" 2>&1 || true

# Extract strings
echo "Extracting strings..."
strings "$PROGRAM_DIR/program.so" > "$OUTPUT_DIR/strings.txt"

# Extract error messages
echo "Extracting error messages..."
strings "$PROGRAM_DIR/program.so" | grep -iE "error|failed|invalid|unauthorized|overflow" > "$OUTPUT_DIR/errors.txt" || true

# Extract instruction names (from strings)
echo "Extracting instruction hints..."
strings "$PROGRAM_DIR/program.so" | grep -E "^Instruction:" > "$OUTPUT_DIR/instructions.txt" || true

# Summary
DISASM_LINES=$(wc -l < "$OUTPUT_DIR/program.asm" | tr -d ' ')
STRING_COUNT=$(wc -l < "$OUTPUT_DIR/strings.txt" | tr -d ' ')

echo ""
echo "Disassembly complete!"
echo "Output directory: $OUTPUT_DIR"
echo "Disassembly lines: $DISASM_LINES"
echo "Strings extracted: $STRING_COUNT"
echo ""
echo "Files generated:"
ls -lh "$OUTPUT_DIR/"
