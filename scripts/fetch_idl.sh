#!/bin/bash
# Fetch Anchor IDL for a Solana program
#
# Usage: ./fetch_idl.sh <program-id> <program-name> [cluster]
# Example: ./fetch_idl.sh DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH dflow mainnet-beta

set -e

PROGRAM_ID="${1:?Error: Program ID required}"
PROGRAM_NAME="${2:?Error: Program name required}"
CLUSTER="${3:-mainnet-beta}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$ROOT_DIR/programs/$PROGRAM_NAME"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Fetching IDL for program: $PROGRAM_ID"
echo "Cluster: $CLUSTER"

# Check if anchor is installed
if ! command -v anchor &> /dev/null; then
    echo "Warning: Anchor CLI not found. Install with:"
    echo "  cargo install --git https://github.com/coral-xyz/anchor anchor-cli"
    exit 1
fi

# Fetch IDL
if anchor idl fetch "$PROGRAM_ID" --provider.cluster "$CLUSTER" > "$OUTPUT_DIR/idl.json" 2>/dev/null; then
    echo "IDL saved to $OUTPUT_DIR/idl.json"

    # Extract program info
    PROGRAM_NAME_IDL=$(jq -r '.metadata.name // "unknown"' "$OUTPUT_DIR/idl.json")
    VERSION=$(jq -r '.metadata.version // "unknown"' "$OUTPUT_DIR/idl.json")
    INSTRUCTION_COUNT=$(jq '.instructions | length' "$OUTPUT_DIR/idl.json")
    ACCOUNT_COUNT=$(jq '.accounts | length' "$OUTPUT_DIR/idl.json")
    ERROR_COUNT=$(jq '.errors | length' "$OUTPUT_DIR/idl.json")
    TYPE_COUNT=$(jq '.types | length' "$OUTPUT_DIR/idl.json")

    echo ""
    echo "Program: $PROGRAM_NAME_IDL v$VERSION"
    echo "Instructions: $INSTRUCTION_COUNT"
    echo "Accounts: $ACCOUNT_COUNT"
    echo "Errors: $ERROR_COUNT"
    echo "Types: $TYPE_COUNT"
else
    echo "Warning: Could not fetch IDL. Program may not be an Anchor program."
    echo "Attempting to extract strings from binary..."

    if [ -f "$OUTPUT_DIR/program.so" ]; then
        strings "$OUTPUT_DIR/program.so" | grep -i "instruction\|account\|error" | head -20
    fi
fi
