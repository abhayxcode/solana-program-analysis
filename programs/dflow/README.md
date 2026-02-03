# DFlow Swap Orchestrator

**Program ID:** `DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH`

DFlow is an intelligent trade execution protocol on Solana, providing DEX aggregation and prediction market infrastructure.

## Overview

| Property | Value |
|----------|-------|
| **Program Name** | `swap_orchestrator` |
| **Version** | 0.1.0 |
| **Framework** | Anchor |
| **Binary Size** | 1.7 MB |
| **Disassembly Lines** | ~199,000 |

## What is DFlow?

DFlow is a trading protocol that provides:

1. **DEX Aggregation** - Routes trades through 36+ liquidity venues for best execution
2. **Order System** - Intent-based trading with escrow and fill mechanism
3. **Prediction Markets** - Tokenized prediction market positions via Kalshi integration
4. **MEV Protection** - Slippage protection and optimal routing

## Instructions (17)

### Order Management

| Instruction | Description |
|-------------|-------------|
| `open_order` | Create an order, escrowing input tokens in vault |
| `fill_order` | Fill an open order (market makers) |
| `close_order` | Close an order, return tokens |

### Swap Operations

| Instruction | Description |
|-------------|-------------|
| `swap` | Execute a direct swap |
| `swap2` | Enhanced swap with additional options |
| `swap_with_destination` | Swap with explicit destination account |
| `swap2_with_destination` | Enhanced swap with destination |
| `swap_with_destination_native` | Swap outputting native SOL |
| `swap2_with_destination_native` | Enhanced swap outputting native SOL |

### Token Operations

| Instruction | Description |
|-------------|-------------|
| `wrap_sol` | Wrap native SOL to wSOL |
| `unwrap_sol` | Unwrap wSOL to native SOL |
| `transfer_sol` | Transfer native SOL |
| `transfer_fee` | Transfer platform fees |
| `transfer_to_sponsor` | Transfer to sponsor account |
| `close_empty_token_account` | Close empty token account |
| `create_referral_token_account_idempotent` | Create referral token account |

### Prediction Markets

| Instruction | Description |
|-------------|-------------|
| `init_market_ledger_idempotent` | Initialize market ledger for prediction markets |

## Account Structure

### Order Account

```rust
#[repr(C)]
struct Order {
    /// Who can close the order
    closer: Pubkey,                      // 32 bytes

    /// Where output tokens go
    output_token_account: Pubkey,        // 32 bytes

    /// Where leftover input returns
    return_input_token_account: Pubkey,  // 32 bytes

    /// Where rent returns on close
    return_rent_to: Pubkey,              // 32 bytes

    /// Unique order ID for PDA
    id: u64,                             // 8 bytes

    /// Expected output amount
    quoted_out_amount: u64,              // 8 bytes

    /// Expiration slot
    last_fillable_slot: u64,             // 8 bytes

    /// Max slippage in basis points
    slippage_bps: u16,                   // 2 bytes

    /// PDA bump seed
    bump: u8,                            // 1 byte

    /// Vault PDA bump seed
    vault_bump: u8,                      // 1 byte

    /// Order flags
    flags: u8,                           // 1 byte

    _padding: [u8; 3],                   // 3 bytes
}
// Total: 160 bytes
```

### PDA Seeds

**Order Account:**
```
seeds = ["order", return_input_token_account, order_account_id]
```

**Order Vault:**
```
seeds = ["order_vault", order]
```

## Supported DEX Venues (36)

DFlow integrates with the following liquidity sources:

### AMMs
- Raydium AMM
- Raydium CP
- Meteora DAMM v1/v2
- Gamma
- Lifinity v2
- Token Swap (SPL)

### CLMMs (Concentrated Liquidity)
- Raydium CLMM
- Orca Whirlpools v1/v2
- Meteora DLMM
- Saros DLMM

### Order Books
- Phoenix
- Manifest
- OpenBook (via integrations)

### Specialized
- PumpFun / PumpFun AMM (meme coins)
- Raydium Launchlab
- Sanctum Infinity (LST)
- Meteora DBC

### Market Makers
- Mozart
- Nexus
- Obric v2
- Rubicon
- HumidiFi
- SolFi v1/v2
- TesseraV
- AlphaQ
- BisonFi
- Clearpools
- Heaven
- Scorch
- Stabble (Stable/Weighted)
- Vertigo
- ZeroFi

## Error Codes

| Code | Name | Description |
|------|------|-------------|
| 15000 | SwapCpiFailed | Cross-program swap call failed |
| 15001 | SlippageLimitExceeded | Output below minimum |
| 15002 | FeeAccountNotSpecified | Fee account required when platform_fee_bps > 0 |
| 15003 | InvalidFeeAccountOwner | Wrong fee account owner |
| 15004 | InputAmountIsZero | Input must be > 0 |
| 15005 | OutputTokenAccountMismatch | Wrong output account |
| 15006 | OrderNotFillableAfterLastFillableSlot | Order expired |
| 15007 | FillOrderNotAuthorized | Filler not authorized |
| 15008 | MintAccountNotSpecified | Mint account required |
| 15009 | ReturnInputTokenAccountMismatch | Wrong return account |
| 15010 | ReturnRentToMismatch | Wrong rent return account |
| 15011 | CloseOrderNotAuthorized | Closer not authorized |
| 15012 | InvalidReturnInputTokenAccount | Invalid return account |
| 15013 | InvalidOutputTokenAccount | Invalid output account |
| 15014 | CouldNotReturnInput | Failed to return input |
| 15015 | LegInputOverconsumption | Leg used too much input |

## Files

| File | Description | Size |
|------|-------------|------|
| `program.so` | BPF binary | 1.7 MB |
| `idl.json` | Anchor IDL | 81 KB |
| `disassembly/program.asm` | Full disassembly | 11 MB |

## Integration Example

```typescript
import { Program, AnchorProvider } from "@coral-xyz/anchor";
import { PublicKey } from "@solana/web3.js";

const DFLOW_PROGRAM_ID = new PublicKey("DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH");

// Load IDL
import idl from "./idl.json";

// Initialize program
const program = new Program(idl, DFLOW_PROGRAM_ID, provider);

// Execute swap
await program.methods
  .swap({
    inputAmount: new BN(1000000),
    minimumOutputAmount: new BN(900000),
    // ... other params
  })
  .accounts({
    userTokenAuthority: wallet.publicKey,
    // ... other accounts
  })
  .rpc();
```

## Resources

- **Website:** https://dflow.net
- **Documentation:** https://pond.dflow.net
- **GitHub:** https://github.com/DFlowProtocol
- **Explorer:** [Solana Explorer](https://explorer.solana.com/address/DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH)
