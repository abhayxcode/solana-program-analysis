#!/bin/bash
# List all analyzed programs
#
# Usage: ./list_programs.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROGRAMS_DIR="$ROOT_DIR/programs"

echo "Analyzed Programs"
echo "================="
echo ""

# Check if any programs exist
if [ ! -d "$PROGRAMS_DIR" ] || [ -z "$(ls -A "$PROGRAMS_DIR" 2>/dev/null)" ]; then
    echo "No programs analyzed yet."
    echo "Run: ./scripts/analyze.sh <program-id> <name>"
    exit 0
fi

# List each program
for dir in "$PROGRAMS_DIR"/*/; do
    if [ -d "$dir" ]; then
        PROGRAM_NAME=$(basename "$dir")

        # Get metadata
        if [ -f "$dir/metadata.json" ]; then
            PROGRAM_ID=$(jq -r '.program_id // "unknown"' "$dir/metadata.json")
            CLUSTER=$(jq -r '.cluster // "unknown"' "$dir/metadata.json")
        else
            PROGRAM_ID="unknown"
            CLUSTER="unknown"
        fi

        # Get binary size
        if [ -f "$dir/program.so" ]; then
            SIZE=$(ls -lh "$dir/program.so" | awk '{print $5}')
        else
            SIZE="N/A"
        fi

        # Check for IDL
        if [ -f "$dir/idl.json" ]; then
            HAS_IDL="Yes"
            INSTRUCTIONS=$(jq '.instructions | length' "$dir/idl.json" 2>/dev/null || echo "?")
        else
            HAS_IDL="No"
            INSTRUCTIONS="?"
        fi

        printf "%-20s %-45s %8s %6s %s\n" "$PROGRAM_NAME" "$PROGRAM_ID" "$SIZE" "$INSTRUCTIONS" "$HAS_IDL"
    fi
done | column -t -s' '
