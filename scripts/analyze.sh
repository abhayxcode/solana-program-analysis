#!/bin/bash
# Full analysis pipeline for a Solana program
#
# Usage: ./analyze.sh <program-id> <program-name> [cluster]
# Example: ./analyze.sh DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH dflow mainnet-beta

set -e

PROGRAM_ID="${1:?Error: Program ID required}"
PROGRAM_NAME="${2:?Error: Program name required}"
CLUSTER="${3:-mainnet-beta}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Solana Program Analysis Pipeline"
echo "=========================================="
echo "Program ID: $PROGRAM_ID"
echo "Name: $PROGRAM_NAME"
echo "Cluster: $CLUSTER"
echo "=========================================="
echo ""

# Step 1: Download
echo "[1/4] Downloading program binary..."
"$SCRIPT_DIR/download.sh" "$PROGRAM_ID" "$PROGRAM_NAME" "$CLUSTER"
echo ""

# Step 2: Fetch IDL
echo "[2/4] Fetching IDL..."
"$SCRIPT_DIR/fetch_idl.sh" "$PROGRAM_ID" "$PROGRAM_NAME" "$CLUSTER" || true
echo ""

# Step 3: Disassemble
echo "[3/4] Disassembling..."
"$SCRIPT_DIR/disassemble.sh" "$PROGRAM_NAME"
echo ""

# Step 4: Generate summary
echo "[4/4] Generating summary..."
"$SCRIPT_DIR/generate_summary.sh" "$PROGRAM_NAME"
echo ""

echo "=========================================="
echo "Analysis complete!"
echo "Results: programs/$PROGRAM_NAME/"
echo "=========================================="
