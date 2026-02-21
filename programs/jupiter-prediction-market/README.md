# Jupiter Prediction Market

**Program ID:** `3ZZuTbwC6aJbvteyVxXUS7gtFYdf7AuXeitx6VyvjvUp`

Jupiter's on-chain prediction market program. Bridges both **Kalshi** and **Polymarket** liquidity to Solana. Manages JUPUSD/USDC-denominated vaults, order creation/filling, position tracking, and payout claims. Uses a CLP (Concurrent Liquidity Program) architecture where users post intents on-chain and keepers fill them against off-chain liquidity from either provider.

## Overview

| Property | Value |
|----------|-------|
| **Program ID** | `3ZZuTbwC6aJbvteyVxXUS7gtFYdf7AuXeitx6VyvjvUp` |
| **Label (Solscan)** | Jupiter Prediction Market |
| **Upgrade Authority** | `HVSZJ2juJnMxd6yCNarTL56YmgUqzfUiwM7y7LtTXKHR` |
| **Source Path** | `programs/prediction-market/src/lib.rs` |
| **Framework** | Anchor |
| **Binary Size** | 685 KB |
| **Disassembly Lines** | ~68,000 |
| **Settlement Token** | JUPUSD (`JuprjznTrTSp2UFa3ZBUFgwdAmtZCq4MQCwysN55USD`) |
| **Outcome Types** | Binary (YES/NO) |
| **On-Chain IDL** | Not published (Anchor framework confirmed, but IDL account empty) |
| **Vaults** | 2 (USDC: `BrTCoKzZoh7waCM3h2MuJKan8fX2A574gedorgPRC3HJ`, JUPUSD: `2y9Ad2GD7gwiMkkMu4bBK5216Pv9YJsBkSHAGwN3rBuJ`) |

> **Note:** This program is deployed and owned by Jupiter (upgrade authority `HVSZJ2ju...` differs from DFlow's programs). The architecture follows a CLP pattern similar to DFlow's design, but this is Jupiter's own program.

## Liquidity Sources

This program bridges **two** off-chain prediction market providers. Verified from on-chain position data (42,111 positions analyzed):

| Provider | Position Count | Share | Market ID Format | Example |
|----------|---------------|-------|-----------------|---------|
| **Kalshi** | 27,945 | ~66% | Human-readable ticker (`KX` prefix or plain) | `KXBTCMAXY-25-DEC31-149999.99` |
| **Polymarket** | 14,166 | ~34% | 128-bit hex hash | `0337b0be97e8f76033e945c566593d81` |

**Kalshi** launched first (late 2025), **Polymarket** was added in February 2026.

### Market ID Formats

- **Kalshi markets** use tickers: `KXBTCMAXY-25-DEC31-149999.99`, `KXEPLGAME-25NOV09MCILFC-MCI`, `GTA6-26DEC31`, `FEDHIKE-26DEC31`
- **Polymarket markets** use 32-char hex hashes (128-bit): `0337b0be97e8f76033e945c566593d81`
- **Order IDs** in fill logs are 256-bit hashes: `0x9bb1323fb269cdd121aeb605095baf9519179439c943509f30f3e260d3a33e35`

### FillBuyOrder Event Data Structure

Each fill event emits two market identifiers and the order hash:
```
market_id:  0337b0be97e8f76033e945c566593d81  (128-bit, stored in position)
event_id:   031c68cf2f00406c93b161673ec76396  (128-bit, secondary identifier)
order_hash: 0x9bb1323fb269cdd1...d3a33e35      (256-bit, order reference)
```

## On-Chain Stats (as of 2026-02-21)

| Metric | Value |
|--------|-------|
| Total Accounts | 64,499 |
| Position Accounts | 42,109 |
| MarketResult Accounts | 22,388 |
| Vault Accounts | 2 |

## How It Works

This program implements an intent-based order system for prediction markets:

1. **Vault Initialization** — Admin sets up a vault with configurable limits (max contracts, fees, settlement delays)
2. **Order Creation** — Users create buy/sell orders specifying market, side (YES/NO), contracts, and price limit
3. **Order Filling** — A keeper fills orders against off-chain liquidity (Kalshi or Polymarket)
4. **Position Tracking** — Filled orders create/update position accounts tracking the user's contracts
5. **Market Settlement** — Admin creates market results when events resolve
6. **Payout Claims** — Users (or keeper) claim payouts for winning positions after settlement delay

```
User (via Jupiter UI at jup.ag/prediction)
    ↓ Jupiter v6 swap (token → JUPUSD)
    ↓ CreateOrder
Jupiter Prediction Market (3ZZuTbw...)
    ↓ observed by
Keeper (8jhWXEL...)
    ↓ fills against
Kalshi / Polymarket (off-chain order books)
    ↓ FillBuyOrder / FillSellOrder
Jupiter Prediction Market → updates position, transfers tokens
```

## Instructions

### Admin Instructions

| Instruction | Description |
|-------------|-------------|
| `InitializeVault` | Create vault and vault config for the prediction market |
| `SetVaultConfig` | Update vault parameters: `max_contracts`, `max_pos_contracts`, `max_pos_orders`, `fee_bps`, `settlement_delay_seconds`, `deposits_disabled`, `withdrawals_disabled`, `trading_disabled` |
| `Withdraw` | Withdraw USDC from vault to destination |
| `CreateMarketResult` | Create result for a resolved market (admin only) |
| `UpdateMarketResult` | Update a market result |

### User Instructions

| Instruction | Description |
|-------------|-------------|
| `CreateOrder` | Create a new buy/sell order on a prediction market |
| `CloseOrder` | Close an unfilled/partially filled order, return funds |
| `CancelOrder` | Cancel an open order |
| `ClaimPayout` | Claim payout for a winning position after settlement |

### Keeper Instructions

| Instruction | Description |
|-------------|-------------|
| `FillBuyOrder` | Fill a user's buy order — transfers funds from vault, updates position |
| `FillSellOrder` | Fill a user's sell order — transfers funds to vault, updates position |
| `ClaimPayout2` | Keeper-initiated payout claim on behalf of user |
| `DisableDeposits` | Keeper can disable vault deposits |
| `DisableWithdrawals` | Keeper can disable vault withdrawals |
| `CloseLostPosition` | Close a position that lost (zero payout) |

### IDL Management (Anchor Standard)

| Instruction | Description |
|-------------|-------------|
| `IdlCreateAccount` | Create IDL account |
| `IdlResizeAccount` | Resize IDL account |
| `IdlCloseAccount` | Close IDL account |
| `IdlCreateBuffer` | Create IDL buffer |
| `IdlWrite` | Write IDL data |
| `IdlSetAuthority` | Set IDL authority |
| `IdlSetBuffer` | Set IDL buffer |

## State Accounts

Identified from binary source paths, on-chain account analysis, and discriminator verification.

| Account | Discriminator | Size | Count | Source |
|---------|--------------|------|-------|--------|
| **Vault** | `0xd308e82b02987577` | 2,000 bytes | 2 | `src/state/vault.rs` |
| **Position** | `0xaabc8fe47a40f7d0` | 171 bytes | 42,109 | `src/state/position.rs` |
| **MarketResult** | `0xe474c0ea7d36458e` | 95 bytes | 22,388 | `src/state/market_result.rs` |
| **Order** | unknown (ephemeral) | ~171 bytes | 0 (closed after fill) | `src/state/order.rs` |

Discriminators verified via `SHA256("account:<Name>")[0..8]` against on-chain data.

### Position Layout (171 bytes) — verified from on-chain data

```
[0:8]         discriminator (0xaabc8fe47a40f7d0)
[8:40]        owner: Pubkey (wallet that placed the order)
[40:44]       market_id_len: u32 (Borsh string length prefix)
[44:44+len]   market_id: String (Kalshi ticker e.g. "KXBTCMAXY-25-DEC31-149999.99" or Polymarket hex e.g. "0337b0be97e8f76033e945c566593d81")
[+0]          side: u8 (0=NO, 1=YES)
[+1]          status: u8
[+2:+10]      contracts: u64 (e.g. 1000000 = 1 contract in micro units)
[+10:+18]     created_at: i64 (unix timestamp)
[+18:...]     additional fields (avg_price, fees, updated_at, padding)
```

Market IDs use either Kalshi ticker format (`KXBTCMAXY-25-DEC31-149999.99`) or Polymarket hex hashes (`0337b0be97e8f76033e945c566593d81`)

### MarketResult Layout (95 bytes) — verified from on-chain data

```
[0:8]         discriminator (0xe474c0ea7d36458e)
[8:12]        market_id_len: u32 (always 32)
[12:44]       market_id: String (32-char hex hash, e.g. "282042bb11bee156bef4cdd263f3f3ed")
[44]          status: u8
[45:53]       settlement_time: i64 (unix timestamp)
[53]          winning_side: u8 (0=NO, 1=YES)
[54:62]       resolution_time: i64 (unix timestamp)
[62]          bump: u8 (PDA bump seed)
[63:95]       padding (zeroes)
```

### Vault Layout (2,000 bytes) — partially decoded

```
[0:8]         discriminator (0xd308e82b02987577)
[8:40]        settlement_mint: Pubkey (USDC or JUPUSD)
[40:72]       authority: Pubkey
[72:2000]     config fields + padding (mostly zeroes)
```

Known vaults:
- `BrTCoKzZoh7waCM3h2MuJKan8fX2A574gedorgPRC3HJ` — settlement mint: USDC (`EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v`)
- `2y9Ad2GD7gwiMkkMu4bBK5216Pv9YJsBkSHAGwN3rBuJ` — settlement mint: JUPUSD (`JuprjznTrTSp2UFa3ZBUFgwdAmtZCq4MQCwysN55USD`)

### Key Account Fields (from log messages)

**Vault Config:**
- `max_contracts` — Maximum contracts per market
- `max_pos_contracts` — Maximum contracts per position
- `max_pos_orders` — Maximum open orders per position
- `fee_bps` — Fee in basis points
- `settlement_delay_seconds` — Delay before claims are enabled
- `deposits_disabled` — Toggle deposits
- `withdrawals_disabled` — Toggle withdrawals
- `trading_disabled` — Toggle trading

**Order Settlement Logs:**
- Buy: `Buy order settled: <order_id> - Contracts: X, Avg Fill: Y, Transferred: Z, Total Cost: W (Base: B, Fee: F)`
- Sell: `Sell order settled: <order_id> - Contracts: X, Avg Fill: Y, Gross: G, Net: N, Fee: F`

**Payout Logs:**
- `Payout claimed: owner=X, position=Y, market_id=Z, side=S, contracts=C, net_payout_usd=P, fee_usd=F, realized_pnl=R`

## Account Contexts (from binary)

### CreateOrder
- `owner` — User creating the order (signer)
- `vault` — Vault account
- `vault_token_account` — Vault's JUPUSD token account
- `order_ata` — Order's associated token account
- `settlement_mint` — JUPUSD mint
- `token_program` — SPL Token program
- `associated_token_program` — ATA program
- `system_program` — System program

### FillBuyOrder / FillSellOrder
- `authority` — Keeper authority (signer)
- `vault` — Vault account
- `vault_token_account` — Vault's JUPUSD token account
- `order` — Order being filled
- `position` — User's position (created/updated)
- `order_ata` — Order's token account

### ClaimPayout / ClaimPayout2
- `owner` / `authority` — User or keeper
- `vault` — Vault account
- `vault_token_account` — Vault's JUPUSD token account
- `position` — Position being claimed
- `market_result` — Resolved market result
- `owner_token_account` — User's JUPUSD token account
- `destination_token_account` — Payout destination

### InitializeVault
- `admin` — Admin authority (signer)
- `vault` — Vault to initialize
- `vault_token_account` — Vault's JUPUSD token account
- `settlement_mint` — JUPUSD mint
- `token_program` — SPL Token program
- `system_program` — System program

## Error Codes

| Error | Message |
|-------|---------|
| `InvalidAdmin` | Invalid admin |
| `InvalidAPIAuthority` | Invalid API authority |
| `InvalidKeeper` | Invalid keeper |
| `InvalidMint` | Invalid mint |
| `InvalidVaultConfig` | Invalid vault config |
| `DepositsDisabled` | Deposits disabled |
| `WithdrawalsDisabled` | Withdrawals disabled |
| `TradingDisabled` | Trading disabled |
| `InvalidMaxContracts` | Invalid max contracts |
| `InvalidMaxOpenOrders` | Invalid max open orders |
| `InvalidFee` | Invalid fee |
| `InvalidDefaults` | Invalid defaults |
| `ContractsBelowMinimum` | Contracts below minimum |
| `EventCreationDisabled` | Event creation disabled |
| `MarketCreationDisabled` | Market creation disabled |
| `MaxEventsExceeded` | Max events exceeded |
| `MathOverflow` | Math overflow |
| `InvalidExpiryTime` | Invalid expiry time |
| `InvalidEventUpdate` | Invalid event update - event is finalized or immutable |
| `EventAlreadyExists` | Event already exists |
| `InvalidSettlementTime` | Invalid settlement time |
| `InvalidOpenTime` | Invalid open time |
| `InvalidCloseTime` | Invalid close time |
| `InvalidEvent` | Invalid event |
| `MarketAlreadySettled` | Market already settled |
| `MarketNotClosed` | Market not closed |
| `MarketNotOpen` | Market not open |
| `MarketNotSettled` | Market not settled |
| `InvalidStatusTransition` | Invalid status transition |
| `ExceedsGlobalLimit` | Exceeds global limit |
| `InvalidMarketStatus` | Invalid market status |
| `EventAlreadyExpired` | Event already expired |
| `EventAlreadyResolved` | Event already resolved |
| `EventAlreadyCancelled` | Event already cancelled |
| `TooManyOpenOrders` | Too many open orders |
| `InvalidTokenAccountOwner` | Invalid token account owner |
| `PositionOwnerMismatch` | Position owner mismatch |
| `InvalidDepositAmount` | Invalid deposit amount |
| `InsufficientFunds` | Insufficient funds |
| `DepositNotAllowedForSell` | Deposit not allowed for sell orders |
| `DepositBelowMinimum` | Deposit amount must be at least $1 |
| `InsufficientContracts` | Insufficient contracts |
| `PositionMaxContractsExceeded` | Position max contracts limit exceeded |
| `GlobalMaxContractsExceeded` | Global max contracts limit exceeded |
| `InvalidOwner` | Invalid owner |
| `InvalidFillData` | Invalid fill data - contracts or price is zero |
| `InvalidFillPrice` | Invalid fill price |
| `MarketStillOpen` | Market still open (before close time) |
| `InvalidOrder` | Invalid order |
| `MissingFillData` | Missing fill data |
| `PartialFillNotAllowed` | Partial fills not allowed (FOK orders only) |
| `FillPriceExceedsLimit` | Fill price exceeds user's limit |
| `InsufficientVaultFunds` | Insufficient vault funds |
| `OrderNotFailed` | Order is not failed |
| `MarketNotResolved` | Market not resolved |
| `PayoutAlreadyClaimed` | Payout already claimed |
| `InsufficientVaultBalance` | Insufficient vault balance |
| `SettlementDelayNotPassed` | Settlement delay not passed |
| `ClaimsNotEnabled` | Claims not enabled |
| `InvalidMarketResult` | Invalid market result |
| `PositionOpenedAfterSettlement` | Position opened after settlement time |
| `InvalidArgument` | Invalid argument |

## Role-Based Access

The program enforces three authority levels:

| Role | Capabilities |
|------|-------------|
| **Admin** | Initialize vault, set config, withdraw funds, create/update market results |
| **Keeper** | Fill orders, claim payouts on behalf of users, disable deposits/withdrawals, close lost positions |
| **User** | Create orders, close/cancel orders, claim own payouts |

There is also a `secondary_authority` referenced in withdraw and some keeper contexts, and an `API authority` for programmatic access control.

## Differences from DFlow Predictions Program (pReDicT...)

| Feature | `pReDicT...` (v1) | `3ZZuTbw...` (this program) |
|---------|-------------------|----------------------------|
| **Settlement Token** | USDC | JUPUSD |
| **Framework** | Native Solana | Anchor |
| **Outcome Tokens** | YES/NO SPL tokens minted on-chain | Positions tracked in accounts (no separate mints) |
| **Order Model** | Init → Fill (two-phase with outcome token minting) | Create → Fill (intent-based with vault settlement) |
| **Market Init** | Via DFlow Swap Orchestrator CPI | Admin creates market results directly |
| **Binary Size** | 373 KB | 685 KB |
| **Token Standard** | SPL Token + Token-2022 | SPL Token |
| **Fill Types** | FillUserOrder, FillOrderV2 | FillBuyOrder, FillSellOrder (explicit sides) |
| **FOK Support** | Not evident | Yes (Partial fills not allowed for FOK orders) |

## On-Chain Observations

**Known Accounts:**

| Account | Role |
|---------|------|
| `8jhWXEL7xbfVhmmTUsJVfKn7o74jDy3uPARPA9TjsZd2` | Keeper / Filler |
| `JuprjznTrTSp2UFa3ZBUFgwdAmtZCq4MQCwysN55USD` | JUPUSD mint (settlement token) |
| `ProdD7SB4T5h7rwSHU6jJEUtm69rEooTzuguwndpNQc` | Production relayer |

**Transaction Pattern (from on-chain tracing):**

Jupiter prediction market transactions show:
1. Jupiter v6 `SharedAccountsRoute` (swap to JUPUSD)
2. `3ZZuTbw...` `CreateOrder` (prediction market order)

Both in the same transaction — confirming Jupiter routes through this program.

## Source Structure (from binary paths)

```
programs/prediction-market/src/
├── lib.rs                              # Program entrypoint, instruction dispatch
├── events.rs                           # Event emission definitions
├── instructions/
│   ├── admin/
│   │   ├── initialize_vault.rs         # Vault + config initialization
│   │   ├── create_market_result.rs     # Create market outcome results
│   │   └── withdraw.rs                 # Admin withdrawals from vault
│   ├── keeper/
│   │   ├── fill_buy_order.rs           # Fill buy orders (mint/transfer)
│   │   ├── fill_sell_order.rs          # Fill sell orders
│   │   ├── claim_payout2.rs            # Keeper-initiated payouts
│   │   ├── close_lost_position.rs      # Close zero-value positions
│   │   ├── disable_deposits.rs         # Toggle deposits off
│   │   └── disable_withdrawals.rs      # Toggle withdrawals off
│   ├── create_order.rs                 # User order creation
│   ├── close_order.rs                  # Close unfilled orders
│   ├── cancel_order.rs                 # Cancel open orders
│   └── claim_payout.rs                 # User payout claims
└── state/
    ├── vault.rs                        # Vault account structure
    ├── order.rs                        # Order account structure
    ├── position.rs                     # Position account structure
    └── market_result.rs                # Market result account structure
```
