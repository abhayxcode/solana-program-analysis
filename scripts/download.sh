#!/bin/bash
# Download a Solana program binary from the chain
#
# Usage: ./download.sh <program-id> <program-name> [cluster]
# Example: ./download.sh DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH dflow mainnet-beta

set -e

PROGRAM_ID="${1:?Error: Program ID required}"
PROGRAM_NAME="${2:?Error: Program name required}"
CLUSTER="${3:-mainnet-beta}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$ROOT_DIR/programs/$PROGRAM_NAME"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Downloading program: $PROGRAM_ID"
echo "Cluster: $CLUSTER"
echo "Output: $OUTPUT_DIR/program.so"

# Download the program
solana program dump "$PROGRAM_ID" "$OUTPUT_DIR/program.so" --url "$CLUSTER"

# Get file info
FILE_SIZE=$(ls -lh "$OUTPUT_DIR/program.so" | awk '{print $5}')
FILE_TYPE=$(file "$OUTPUT_DIR/program.so")

echo ""
echo "Download complete!"
echo "Size: $FILE_SIZE"
echo "Type: $FILE_TYPE"

# Save metadata
cat > "$OUTPUT_DIR/metadata.json" << EOF
{
  "program_id": "$PROGRAM_ID",
  "cluster": "$CLUSTER",
  "downloaded_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "file_size": "$(ls -l "$OUTPUT_DIR/program.so" | awk '{print $5}')"
}
EOF

echo "Metadata saved to $OUTPUT_DIR/metadata.json"
