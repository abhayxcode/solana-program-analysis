# Solana Program Analysis

A toolkit for downloading, disassembling, and analyzing Solana programs. Designed to be extensible for adding multiple programs.

## Repository Structure

```
.
├── programs/                    # Analyzed programs
│   └── <program-name>/
│       ├── README.md           # Program-specific documentation
│       ├── program.so          # Downloaded BPF binary
│       ├── idl.json            # Anchor IDL (if available)
│       └── disassembly/
│           └── program.asm     # Disassembled bytecode
├── scripts/                     # Automation scripts
│   ├── analyze.sh              # Full analysis pipeline
│   ├── download.sh             # Download program binary
│   ├── disassemble.sh          # Disassemble BPF bytecode
│   └── fetch_idl.sh            # Fetch Anchor IDL
├── docs/                        # Documentation
│   └── analysis-guide.md       # How to analyze programs
└── config/
    └── programs.json           # Registry of programs
```

## Quick Start

### Prerequisites

- [Solana CLI](https://docs.solana.com/cli/install-solana-cli-tools) (v1.14+)
- [Anchor CLI](https://www.anchor-lang.com/docs/installation) (optional, for IDL fetching)
- [LLVM](https://llvm.org/) (for disassembly)

```bash
# macOS
brew install solana llvm

# Install Anchor (optional)
cargo install --git https://github.com/coral-xyz/anchor anchor-cli
```

### Analyze a New Program

```bash
# Using the full pipeline
./scripts/analyze.sh <program-id> <program-name>

# Example: Analyze Jupiter Aggregator
./scripts/analyze.sh JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4 jupiter
```

### Manual Steps

```bash
# 1. Download program binary
./scripts/download.sh <program-id> <program-name>

# 2. Fetch IDL (if Anchor program)
./scripts/fetch_idl.sh <program-id> <program-name>

# 3. Disassemble
./scripts/disassemble.sh <program-name>
```

## Analyzed Programs

| Program | Address | Type | Status |
|---------|---------|------|--------|
| [DFlow Swap Orchestrator](./programs/dflow-swap-orchestrator/) | `DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH` | DEX Aggregator (Anchor) | Complete |
| [DFlow Outcome Token Engine](./programs/dflow-outcome-token-engine/) | `pReDicTmksnPfkfiz33ndSdbe2dY43KYPg4U2dbvHvb` | Prediction Market Engine (Native) | Complete |
| [DFlow Prediction Market CLP](./programs/dflow-prediction-market-clp/) | `3ZZuTbwC6aJbvteyVxXUS7gtFYdf7AuXeitx6VyvjvUp` | Jupiter Prediction Market (Anchor) | Complete |
| [Jupiter v6 Aggregator](./programs/jupiter-v6-aggregator/) | `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4` | DEX Aggregator (Hybrid) | Complete |
| [Squads Smart Account](./programs/squads-smart-account/) | `SMRTzfY6DfH5ik3TKiyLFfXexV8uSG3d2UksSCYdunG` | Multisig Smart Account (Anchor) | Complete |

## Adding a New Program

1. Add the program to `config/programs.json`:
   ```json
   {
     "name": "my-program",
     "address": "PROGRAM_ADDRESS_HERE",
     "cluster": "mainnet-beta",
     "type": "anchor"
   }
   ```

2. Run the analysis:
   ```bash
   ./scripts/analyze.sh PROGRAM_ADDRESS my-program
   ```

3. Create documentation in `programs/my-program/README.md`

## Documentation

- [Analysis Guide](./docs/analysis-guide.md) - Detailed guide on analyzing Solana programs
- [DFlow Swap Orchestrator](./programs/dflow-swap-orchestrator/README.md) - DEX aggregator analysis
- [DFlow Outcome Token Engine](./programs/dflow-outcome-token-engine/README.md) - Prediction market outcome tokens
- [DFlow Prediction Market CLP](./programs/dflow-prediction-market-clp/README.md) - Jupiter's prediction market program
- [Jupiter v6 Aggregator](./programs/jupiter-v6-aggregator/SUMMARY.md) - Jupiter DEX aggregator
- [Squads Smart Account](./programs/squads-smart-account/SUMMARY.md) - Squads multisig

## Tools Used

| Tool | Purpose |
|------|---------|
| `solana program dump` | Download program binary from chain |
| `anchor idl fetch` | Fetch Anchor IDL from chain |
| `llvm-objdump` | Disassemble eBPF bytecode |
| `strings` | Extract readable strings from binary |
| `jq` | Parse and format JSON |

## License

MIT
