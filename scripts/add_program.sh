#!/bin/bash
# Add a new program to the registry and analyze it
#
# Usage: ./add_program.sh <program-id> <program-name> [description]
# Example: ./add_program.sh JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4 jupiter "Jupiter Aggregator v6"

set -e

PROGRAM_ID="${1:?Error: Program ID required}"
PROGRAM_NAME="${2:?Error: Program name required}"
DESCRIPTION="${3:-Solana program}"
CLUSTER="${4:-mainnet-beta}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$ROOT_DIR/config/programs.json"

echo "Adding program: $PROGRAM_NAME"
echo "Address: $PROGRAM_ID"
echo ""

# Check if program already exists
if jq -e ".programs[] | select(.name == \"$PROGRAM_NAME\")" "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "Program '$PROGRAM_NAME' already exists in registry."
    read -p "Update and re-analyze? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    # Add to registry
    echo "Adding to registry..."
    jq ".programs += [{
        \"name\": \"$PROGRAM_NAME\",
        \"address\": \"$PROGRAM_ID\",
        \"cluster\": \"$CLUSTER\",
        \"type\": \"unknown\",
        \"description\": \"$DESCRIPTION\"
    }]" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
fi

# Run analysis
echo ""
"$SCRIPT_DIR/analyze.sh" "$PROGRAM_ID" "$PROGRAM_NAME" "$CLUSTER"

# Update type in registry if IDL was found
if [ -f "$ROOT_DIR/programs/$PROGRAM_NAME/idl.json" ]; then
    jq "(.programs[] | select(.name == \"$PROGRAM_NAME\")).type = \"anchor\"" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Updated program type to 'anchor' in registry."
fi

echo ""
echo "Program added successfully!"
echo "View analysis: programs/$PROGRAM_NAME/"
