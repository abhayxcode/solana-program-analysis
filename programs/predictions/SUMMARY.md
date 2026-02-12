# predictions Analysis Summary

Generated: 2026-02-12

## Program Info

| Property | Value |
|----------|-------|
| Program ID | `pReDicTmksnPfkfiz33ndSdbe2dY43KYPg4U2dbvHvb` |
| Cluster | mainnet-beta |
| Downloaded | 2026-02-12 |
| Binary Size | 373K |
| File Type | ELF 64-bit LSB shared object (eBPF) |
| Has IDL | No (native program, no on-chain Anchor IDL) |
| Program Data | `4egn6ER5xjGcY5sFDKRiqtgo3LfRDQzQHS4yeT4YiWkk` |

## Program Summary

DFlow/Kalshi Predictions Program - the core on-chain engine for tokenized prediction markets on Solana. Manages market creation, order execution (buy/sell), settlement escrows, and YES/NO outcome token minting/burning.

## Instructions (from binary analysis)

| Instruction | Description |
|-------------|-------------|
| `InitMarketLedger` | Create market ledger, vaults, and outcome mints |
| `InitOrderV2` | Create buy/sell order with escrow |
| `FillOrderV2` | Fill order (mint/burn outcome tokens) |
| `FundOrderV2` | Fund order from settlement escrow |
| `FillUserOrder` | Fill user order |
| `InitUserReduceOrderEscrow` | Init position reduction escrow |
| `FillUserReduce` | Fill position reduction |
| `FundUserReduce` | Fund position reduction |
| `RedeemMarketOutcome` | Redeem winning tokens for payout |
| `close_order` | Close order, return unfilled funds |

## Disassembly Summary

| Metric | Value |
|--------|-------|
| Assembly Lines | 42,133 |
| Strings Extracted | 124 |

## Source Crates (from binary paths)

- `crates/predictions-program/src/processors/`
- `crates/predictions-core/src/instructions/`
- `crates/predictions-core/src/common.rs`

## Files

```
programs/predictions/
  program.so           373K   BPF binary
  metadata.json        163B   Program metadata
  README.md                   Comprehensive documentation
  SUMMARY.md                  This file
  disassembly/
    program.asm        2.2M   Full eBPF disassembly
    strings.txt        9.2K   Extracted strings
    errors.txt         7.8K   Error patterns
    sections.txt       616B   ELF section headers
    symbols.txt        138B   Symbol table
    instructions.txt   0B     (no Anchor instruction names)
```
