# prediction-market Analysis Summary

Generated: 2026-02-21

## Program Info

| Property | Value |
|----------|-------|
| Program ID | `3ZZuTbwC6aJbvteyVxXUS7gtFYdf7AuXeitx6VyvjvUp` |
| Cluster | mainnet-beta |
| Binary Size | 685K |
| Framework | Anchor (IDL on-chain but fetch failed — instructions recovered from binary strings) |
| Settlement Token | JUPUSD (`JuprjznTrTSp2UFa3ZBUFgwdAmtZCq4MQCwysN55USD`) |
| Source Path | `programs/prediction-market/src/lib.rs` |

## Instructions (14 discovered from binary)

| # | Instruction | Category |
|---|-------------|----------|
| 1 | InitializeVault | Admin |
| 2 | SetVaultConfig | Admin |
| 3 | Withdraw | Admin |
| 4 | CreateMarketResult | Admin |
| 5 | UpdateMarketResult | Admin |
| 6 | CreateOrder | User |
| 7 | CloseOrder | User |
| 8 | CancelOrder | User |
| 9 | ClaimPayout | User |
| 10 | FillBuyOrder | Keeper |
| 11 | FillSellOrder | Keeper |
| 12 | ClaimPayout2 | Keeper |
| 13 | DisableDeposits | Keeper |
| 14 | DisableWithdrawals | Keeper |
| 15 | CloseLostPosition | Keeper |

## State Accounts (4)

| Account | Source File |
|---------|------------|
| Vault | `src/state/vault.rs` |
| Order | `src/state/order.rs` |
| Position | `src/state/position.rs` |
| MarketResult | `src/state/market_result.rs` |

## Disassembly Summary

| Metric | Value |
|--------|-------|
| Assembly Lines | 68,101 |
| Strings Extracted | 1,045 |
| Custom Errors | 48 |

## Files

| File | Size | Purpose |
|------|------|---------|
| `program.so` | 685 KB | BPF binary |
| `metadata.json` | — | Download metadata |
| `README.md` | — | Full documentation |
| `disassembly/program.asm` | 3.7 MB | Full disassembly |
| `disassembly/strings.txt` | 22 KB | Extracted strings |
| `disassembly/errors.txt` | 14 KB | Error patterns |
| `disassembly/sections.txt` | — | ELF sections |
| `disassembly/symbols.txt` | — | Symbol table |
