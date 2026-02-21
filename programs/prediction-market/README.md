# DFlow Prediction Market CLP

**Program ID:** `3ZZuTbwC6aJbvteyVxXUS7gtFYdf7AuXeitx6VyvjvUp`

The DFlow Prediction Market CLP (Concurrent Liquidity Program) is the on-chain settlement engine that powers Jupiter's prediction market feature. It manages a JUPUSD-denominated vault, order creation/filling, position tracking, and payout claims for tokenized Kalshi prediction markets on Solana.

## Overview

| Property | Value |
|----------|-------|
| **Program ID** | `3ZZuTbwC6aJbvteyVxXUS7gtFYdf7AuXeitx6VyvjvUp` |
| **Source Path** | `programs/prediction-market/src/lib.rs` |
| **Framework** | Anchor |
| **Binary Size** | 685 KB |
| **Disassembly Lines** | ~68,000 |
| **Settlement Token** | JUPUSD (`JuprjznTrTSp2UFa3ZBUFgwdAmtZCq4MQCwysN55USD`) |
| **Outcome Types** | Binary (YES/NO) |

## How It Works

This program implements an intent-based order system for prediction markets:

1. **Vault Initialization** — Admin sets up a vault with configurable limits (max contracts, fees, settlement delays)
2. **Order Creation** — Users create buy/sell orders specifying market, side (YES/NO), contracts, and price limit
3. **Order Filling** — A keeper (DFlow's off-chain relayer) fills orders against Kalshi liquidity
4. **Position Tracking** — Filled orders create/update position accounts tracking the user's contracts
5. **Market Settlement** — Admin creates market results when events resolve
6. **Payout Claims** — Users (or keeper) claim payouts for winning positions after settlement delay

```
User (via Jupiter UI)
    ↓ CreateOrder
DFlow Prediction Market CLP (3ZZuTbw...)
    ↓ observed by
DFlow Keeper (8jhWXEL...)
    ↓ fills against
Kalshi (off-chain order book)
    ↓ FillBuyOrder / FillSellOrder
DFlow Prediction Market CLP → updates position, transfers tokens
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

Identified from binary source paths and string analysis:

| Account | Source | Description |
|---------|--------|-------------|
| **Vault** | `src/state/vault.rs` | Holds JUPUSD liquidity, tracks config (fees, limits, toggles) |
| **Order** | `src/state/order.rs` | Individual buy/sell order with market ID, side, contracts, price limit |
| **Position** | `src/state/position.rs` | User's position in a market (contracts held, side, entry cost) |
| **MarketResult** | `src/state/market_result.rs` | Resolved market outcome (which side won) |

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
| `ProdD7SB4T5h7rwSHU6jJEUtm69rEooTzuguwndpNQc` | DFlow production relayer |

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
