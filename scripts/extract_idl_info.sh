#!/bin/bash
# Extract detailed information from an IDL file
#
# Usage: ./extract_idl_info.sh <program-name>
# Example: ./extract_idl_info.sh dflow

set -e

PROGRAM_NAME="${1:?Error: Program name required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROGRAM_DIR="$ROOT_DIR/programs/$PROGRAM_NAME"
IDL_FILE="$PROGRAM_DIR/idl.json"
OUTPUT_DIR="$PROGRAM_DIR/analysis"

# Check if IDL exists
if [ ! -f "$IDL_FILE" ]; then
    echo "Error: IDL not found at $IDL_FILE"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Extracting IDL information for $PROGRAM_NAME..."

# Basic metadata
echo "Extracting metadata..."
jq '.metadata' "$IDL_FILE" > "$OUTPUT_DIR/metadata.json"

# Instructions
echo "Extracting instructions..."
jq '[.instructions[] | {
    name: .name,
    discriminator: .discriminator,
    accounts: [.accounts[].name],
    args: [.args[]? | {name: .name, type: .type}]
}]' "$IDL_FILE" > "$OUTPUT_DIR/instructions.json"

# Simple instruction list
jq -r '.instructions[].name' "$IDL_FILE" > "$OUTPUT_DIR/instruction_names.txt"

# Accounts
echo "Extracting accounts..."
jq '.accounts' "$IDL_FILE" > "$OUTPUT_DIR/accounts.json"

# Errors
echo "Extracting errors..."
jq '.errors' "$IDL_FILE" > "$OUTPUT_DIR/errors.json"

# Error lookup table
jq -r '.errors[] | "\(.code)\t\(.name)\t\(.msg)"' "$IDL_FILE" > "$OUTPUT_DIR/error_codes.tsv"

# Types
echo "Extracting types..."
jq '.types' "$IDL_FILE" > "$OUTPUT_DIR/types.json"

# Type names only
jq -r '.types[].name' "$IDL_FILE" > "$OUTPUT_DIR/type_names.txt"

# Extract venue names (for DEX aggregators)
echo "Extracting venue types..."
jq -r '.types[] | select(.name | contains("SwapOptions") or contains("Options")) | .name' "$IDL_FILE" | \
    sed 's/SwapOptions//' | sed 's/DynamicRouteV1Options//' | sed 's/Options//' | \
    grep -v '^$' | sort -u > "$OUTPUT_DIR/venues.txt"

# Summary
INSTRUCTION_COUNT=$(jq '.instructions | length' "$IDL_FILE")
ACCOUNT_COUNT=$(jq '.accounts | length' "$IDL_FILE")
ERROR_COUNT=$(jq '.errors | length' "$IDL_FILE")
TYPE_COUNT=$(jq '.types | length' "$IDL_FILE")

cat > "$OUTPUT_DIR/summary.json" << EOF
{
  "program": "$PROGRAM_NAME",
  "instructions": $INSTRUCTION_COUNT,
  "accounts": $ACCOUNT_COUNT,
  "errors": $ERROR_COUNT,
  "types": $TYPE_COUNT,
  "extracted_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo ""
echo "Extraction complete!"
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Summary:"
echo "  Instructions: $INSTRUCTION_COUNT"
echo "  Accounts: $ACCOUNT_COUNT"
echo "  Errors: $ERROR_COUNT"
echo "  Types: $TYPE_COUNT"
echo ""
echo "Files generated:"
ls -1 "$OUTPUT_DIR/"
