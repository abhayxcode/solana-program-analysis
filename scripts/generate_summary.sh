#!/bin/bash
# Generate analysis summary for a program
#
# Usage: ./generate_summary.sh <program-name>
# Example: ./generate_summary.sh dflow

set -e

PROGRAM_NAME="${1:?Error: Program name required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PROGRAM_DIR="$ROOT_DIR/programs/$PROGRAM_NAME"

# Check if program exists
if [ ! -d "$PROGRAM_DIR" ]; then
    echo "Error: Program directory not found: $PROGRAM_DIR"
    exit 1
fi

SUMMARY_FILE="$PROGRAM_DIR/SUMMARY.md"

# Get metadata
PROGRAM_ID=$(jq -r '.program_id // "unknown"' "$PROGRAM_DIR/metadata.json" 2>/dev/null || echo "unknown")
CLUSTER=$(jq -r '.cluster // "unknown"' "$PROGRAM_DIR/metadata.json" 2>/dev/null || echo "unknown")
DOWNLOADED_AT=$(jq -r '.downloaded_at // "unknown"' "$PROGRAM_DIR/metadata.json" 2>/dev/null || echo "unknown")

# Get binary info
BINARY_SIZE=$(ls -lh "$PROGRAM_DIR/program.so" 2>/dev/null | awk '{print $5}' || echo "N/A")
FILE_TYPE=$(file "$PROGRAM_DIR/program.so" 2>/dev/null | cut -d: -f2 | xargs || echo "N/A")

# Get IDL info if available
if [ -f "$PROGRAM_DIR/idl.json" ]; then
    IDL_NAME=$(jq -r '.metadata.name // "unknown"' "$PROGRAM_DIR/idl.json")
    IDL_VERSION=$(jq -r '.metadata.version // "unknown"' "$PROGRAM_DIR/idl.json")
    INSTRUCTION_COUNT=$(jq '.instructions | length' "$PROGRAM_DIR/idl.json")
    ACCOUNT_COUNT=$(jq '.accounts | length' "$PROGRAM_DIR/idl.json")
    ERROR_COUNT=$(jq '.errors | length' "$PROGRAM_DIR/idl.json")
    TYPE_COUNT=$(jq '.types | length' "$PROGRAM_DIR/idl.json")
    HAS_IDL="Yes"
else
    IDL_NAME="N/A"
    IDL_VERSION="N/A"
    INSTRUCTION_COUNT="N/A"
    ACCOUNT_COUNT="N/A"
    ERROR_COUNT="N/A"
    TYPE_COUNT="N/A"
    HAS_IDL="No"
fi

# Get disassembly info
if [ -f "$PROGRAM_DIR/disassembly/program.asm" ]; then
    DISASM_LINES=$(wc -l < "$PROGRAM_DIR/disassembly/program.asm" | tr -d ' ')
else
    DISASM_LINES="N/A"
fi

if [ -f "$PROGRAM_DIR/disassembly/strings.txt" ]; then
    STRING_COUNT=$(wc -l < "$PROGRAM_DIR/disassembly/strings.txt" | tr -d ' ')
else
    STRING_COUNT="N/A"
fi

# Generate summary
cat > "$SUMMARY_FILE" << EOF
# $PROGRAM_NAME Analysis Summary

Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Program Info

| Property | Value |
|----------|-------|
| Program ID | \`$PROGRAM_ID\` |
| Cluster | $CLUSTER |
| Downloaded | $DOWNLOADED_AT |
| Binary Size | $BINARY_SIZE |
| File Type | $FILE_TYPE |
| Has IDL | $HAS_IDL |

## IDL Summary

| Metric | Count |
|--------|-------|
| Name | $IDL_NAME |
| Version | $IDL_VERSION |
| Instructions | $INSTRUCTION_COUNT |
| Accounts | $ACCOUNT_COUNT |
| Errors | $ERROR_COUNT |
| Types | $TYPE_COUNT |

## Disassembly Summary

| Metric | Value |
|--------|-------|
| Assembly Lines | $DISASM_LINES |
| Strings Extracted | $STRING_COUNT |

## Files

\`\`\`
$(ls -lh "$PROGRAM_DIR/" 2>/dev/null | tail -n +2)
\`\`\`

EOF

# Add instructions list if IDL exists
if [ -f "$PROGRAM_DIR/idl.json" ]; then
    echo "## Instructions" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    jq -r '.instructions[] | "- `\(.name)`"' "$PROGRAM_DIR/idl.json" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
fi

# Add errors list if IDL exists
if [ -f "$PROGRAM_DIR/idl.json" ]; then
    echo "## Error Codes" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    echo "| Code | Name | Message |" >> "$SUMMARY_FILE"
    echo "|------|------|---------|" >> "$SUMMARY_FILE"
    jq -r '.errors[] | "| \(.code) | \(.name) | \(.msg) |"' "$PROGRAM_DIR/idl.json" | head -20 >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
fi

echo "Summary generated: $SUMMARY_FILE"
