# DFlow Predictions Program

**Program ID:** `pReDicTmksnPfkfiz33ndSdbe2dY43KYPg4U2dbvHvb`

The DFlow Predictions Program is the core on-chain engine for tokenized prediction markets on Solana. It manages market creation, order execution, settlement escrows, and outcome token minting/burning for the DFlow/Kalshi prediction market integration.

## Overview

| Property | Value |
|----------|-------|
| **Program Name** | `predictions-program` |
| **Crate** | `crates/predictions-program` |
| **Core Library** | `crates/predictions-core` |
| **Framework** | Native Solana (no Anchor IDL on-chain) |
| **Binary Size** | 373 KB |
| **Disassembly Lines** | ~42,000 |
| **Outcome Types** | Binary (YES/NO) |
| **Metadata URI** | `https://c.dflow.net/` |

## What Does This Program Do?

This program provides the complete lifecycle for tokenized prediction markets:

1. **Market Creation** - Initialize market ledgers with YES/NO outcome token mints
2. **Order Placement** - Users place buy/sell orders backed by escrow
3. **Order Filling** - Liquidity providers fill orders, minting/burning outcome tokens
4. **Position Reduction** - Users can reduce positions by burning outcome tokens
5. **Settlement** - Markets settle and winning tokens are redeemed for payout

## Instructions (Discovered from Binary Strings)

### Market Lifecycle

| Instruction | Description |
|-------------|-------------|
| `InitMarketLedger` | Create market ledger, vaults, and YES/NO outcome mints |
| `RedeemMarketOutcome` | Redeem winning outcome tokens after market settlement |

### Order Management

| Instruction | Description |
|-------------|-------------|
| `InitOrderV2` | Create a new order (BUY/SELL) with escrowed funds |
| `FillOrderV2` | Fill an existing order (process buy or sell fill) |
| `FundOrderV2` | Fund an order from the settlement escrow |
| `FillUserOrder` | Fill a user's order with outcome tokens |
| `close_order` | Close an order and return unfilled funds |

### Position Reduction

| Instruction | Description |
|-------------|-------------|
| `InitUserReduceOrderEscrow` | Initialize escrow for reducing a position |
| `FillUserReduce` | Fill a user's reduce order (burn outcome tokens) |
| `FundUserReduce` | Fund a user reduce from settlement escrow |

### Events

| Instruction | Description |
|-------------|-------------|
| `emit_event_ix` | Emit on-chain events for indexing |

## Account Structure

### Market Ledger

The central account for each prediction market.

**PDA Seeds:** Derived from the program and market parameters.

**Associated Vaults:**

| Account | Purpose |
|---------|---------|
| `marketLedgerRedemptionVault` | Holds funds for redeeming winning positions |
| `marketLedgerOrderVault` | Holds escrowed funds from active orders |
| `marketLedgerReduceVault` | Holds tokens being reduced |

### Settlement Escrow

Manages collateral for market settlement.

| Account | Purpose |
|---------|---------|
| `settlementEscrow` | Primary escrow account |
| `settlementEscrowVault` | Token vault for escrowed funds |

### Outcome Mints

Each market has two SPL token mints:

| Mint | Description |
|------|-------------|
| `market_yes_outcome_mint` | YES outcome token (0 decimals) |
| `market_no_outcome_mint` | NO outcome token (0 decimals) |

**Metadata URI prefix:** `https://c.dflow.net/`

### Order Accounts

| Account | Purpose |
|---------|---------|
| `orderV2` | Order state (BUY or SELL) |
| `userOrderEscrow` | User's escrowed funds for the order |
| `userReduceEscrow` | User's escrow for position reduction |

### Per-User Accounts

| Account | Purpose |
|---------|---------|
| `user_input_vault` | User's input token vault |
| `user_quote_vault` | User's quote token vault |
| `user_outcome_vault` | User's outcome token vault |

## Order Flow

### Buy Order Flow

```
1. InitOrderV2 (BUY)
   -> transfer_user_funds_to_market_ledger_order_vault
   -> Create settlement escrow (if needed)

2. FillOrderV2
   -> process_buy_fill
   -> transfer_funds_from_market_ledger_to_settlement_escrow
   -> mint_outcome_tokens (YES or NO tokens sent to user)
   -> transfer_remaining_from_market_ledger_to_refund_recipient_on_buy

3. Platform Fees (optional)
   -> transfer_from_market_ledger_to_platform_fee_recipient_on_buy
```

### Sell Order Flow

```
1. InitOrderV2 (SELL)
   -> Escrow outcome tokens

2. FillOrderV2
   -> process_sell_fill
   -> burn_outcome_tokens_on_sell
   -> transfer_from_settlement_escrow_to_fill_recipient_on_sell
   -> transfer_remaining_from_market_ledger_to_refund_recipient_on_sell

3. Platform Fees (optional)
   -> transfer_from_settlement_escrow_to_platform_fee_recipient_on_sell
```

### Position Reduction Flow

```
1. InitUserReduceOrderEscrow
   -> Create user reduce escrow account

2. FillUserReduce
   -> transfer_remaining_outcome_tokens_to_user
   -> transfer_filled_notional_to_fill_recipient
   -> burn_filled_outcome_tokens

3. Platform Fees (optional)
   -> transfer_filled_platform_fee_to_platform_fee_recipient
```

### Market Redemption Flow

```
1. RedeemMarketOutcome
   -> Verify user holds winning outcome tokens
   -> transfer_funds_from_settlement_escrow_to_settlement_authority
   -> Burn redeemed outcome tokens
```

## Account Validation Checks

The program validates the following accounts on every instruction (from binary strings):

- `program` / `events_authority`
- `market_ledger` / `market_ledger_redemption_vault` / `market_ledger_order_vault`
- `market_ledger_reduce_yes_vault` / `market_ledger_reduce_no_vault`
- `settlement_escrow` / `settlement_escrow_vault`
- `escrow_mint` / `market_yes_outcome_mint` / `market_no_outcome_mint`
- `payer` / `user` / `settlement_authority`
- `outcome_token_program` / `escrow_token_program` / `system_program`
- `input_token_program` / `output_token_program` / `quote_token_program`
- `associated_token_program`
- `order` / `user_order_escrow` / `user_reduce_escrow`
- `fill_recipient_token_account` / `fill_recipient_vault`
- `refund_token_account` / `recipient_vault`
- `old_settlement_authority` / `new_settlement_authority`

## Error Messages

| Category | Error |
|----------|-------|
| **Market State** | `market is not open` |
| **Order State** | `order is already filled`, `order is fully funded` |
| **Amount Validation** | `input_amount is 0`, `produced output amount is less than min output amount` |
| **Overflow Protection** | `consumed_input_amount underflow`, `remaining_input_amount underflow`, `fill_total_input_amount overflow` |
| **Fill Validation** | `fill consumed more than remaining input amount`, `fill consumed more than escrowed` |
| **Escrow** | `settlement escrow vault does not have enough funds`, `total filled notional is greater than settlement escrow vault amount` |
| **Account Mismatch** | `user mismatch`, `fill recipient mismatch`, `settlement escrow mismatch`, `input vault mismatch`, `output mint mismatch` |
| **Authorization** | `invalid cancel authority`, `refund recipient mismatch`, `platform fee recipient mismatch` |
| **PDA Validation** | `market ledger PDA mismatch`, `settlement escrow PDA mismatch`, `order v2 PDA mismatch`, `outcome mint PDA mismatch` |
| **Unimplemented** | `scalar outcome should never be used as a PDA seed`, `reduce vault for scalar outcome should never be created` |

## Source Code Structure (from Binary Paths)

```
crates/
  predictions-program/
    src/
      processors/
        init_market_ledger.rs
        init_user_reduce_order_escrow.rs
  predictions-core/
    src/
      common.rs
      instructions/
        emit_event_ix.rs
```

## Cross-Reference with DFlow Swap Orchestrator

The DFlow Swap Orchestrator (`DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH`) integrates with this program via:

| DFlow Instruction | Predictions Program Interaction |
|-------------------|--------------------------------|
| `init_market_ledger_idempotent` | Passes this program as `predictions_program` (account 0) |
| `OpenPredictionsOrder` (swap action) | Creates orders through this program |

**Account name alignment confirmed:** The account names in DFlow's IDL (`market_ledger`, `settlement_escrow`, `market_yes_outcome_mint`, `market_no_outcome_mint`, etc.) match exactly with the account validation checks in this program.

## Design Notes

- **Binary outcomes only**: The program has code paths for "scalar" outcomes but they are explicitly marked as `not implemented` - only YES/NO binary outcomes are supported
- **Platform fees**: Optional platform fees can be charged on fills, with dedicated fee recipient vaults
- **Token program support**: Supports both SPL Token (`TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`) and Token-2022 (`TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`)
- **Event emission**: Includes `eventsAuthority` and event emission for off-chain indexing
- **Upgradeable**: Program is owned by `BPFLoaderUpgradeab1e` with program data at `4egn6ER5xjGcY5sFDKRiqtgo3LfRDQzQHS4yeT4YiWkk`

## Files

| File | Description | Size |
|------|-------------|------|
| `program.so` | BPF binary | 373 KB |
| `metadata.json` | Program metadata | 163 B |
| `SUMMARY.md` | Auto-generated summary | - |
| `disassembly/program.asm` | Full eBPF disassembly | 2.2 MB |
| `disassembly/strings.txt` | Extracted strings | 9.2 KB |
| `disassembly/errors.txt` | Error patterns | 7.8 KB |
| `disassembly/sections.txt` | ELF section headers | 616 B |
| `disassembly/symbols.txt` | Symbol table | 138 B |

## Resources

- **Website:** https://dflow.net
- **Documentation:** https://pond.dflow.net
- **GitHub:** https://github.com/DFlowProtocol
- **Explorer:** [Solana Explorer](https://explorer.solana.com/address/pReDicTmksnPfkfiz33ndSdbe2dY43KYPg4U2dbvHvb)
- **DFlow Swap Orchestrator:** [Analysis](../dflow/README.md)
