# Jupiter v6 Program Analysis

**Program ID:** `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4`  
**Binary Size:** 2.8 MB  
**Framework:** Hybrid (Anchor-like with custom entrypoint)  
**IDL Available:** ❌ No (not a standard Anchor program)

---

## Analysis Summary

| Metric | Value |
|--------|-------|
| Disassembly Lines | 145,537 |
| Strings Extracted | 737 |
| Binary Sections | 8 |
| Integrated DEXes | 35+ |

---

## Instructions (Extracted from Strings)

| Instruction | Description |
|-------------|-------------|
| `Route` | Basic swap route |
| `RouteV2` | Enhanced swap route |
| `RouteWithTokenLedger` | Route with token tracking |
| `SharedAccountsRoute` | Optimized multi-hop swap |
| `SharedAccountsRouteV2` | Enhanced shared accounts swap |
| `SharedAccountsRouteWithTokenLedger` | Combined features |
| `ExactOutRoute` | Exact output amount swap |
| `ExactOutRouteV2` | Enhanced exact output |
| `SharedAccountsExactOutRoute` | Shared accounts exact out |
| `SharedAccountsExactOutRouteV2` | Enhanced shared exact out |
| `SetTokenLedger` | Configure token ledger |
| `Claim` | Claim rewards/tokens |
| `ClaimToken` | Claim specific token |
| `CloseToken` | Close token account |
| `CreateTokenLedger` | Create ledger account |
| `CreateTokenAccount` | Create token account |

---

## Integrated DEX/AMM Venues

### AMMs
- AlphaQ
- Aquifer
- BisonFi
- Crema
- DefiTuna
- Deltafi
- Goonfi / Goonfi V2
- Humidifi
- Invariant
- Mercurial
- Meteora / Meteora DAMM V2 / Meteora DLMM
- Meteora Dynamic Bonding Curve
- OpenBook V2
- Perena Star
- Perps
- Phoenix
- Pump
- Raydium CLMM / Raydium Launchlab
- Sanctum S
- Saros DLMM
- Scorch
- Sencha
- SolFi / SolFi V2
- Stakedex
- Symmetry
- Token Swap / Token Swap V2
- Vault Liquid Unstake
- Virtuals
- Whirlpool (Orca)
- ZeroFi

### Third-Party SDKs Embedded
- Tessera SDK
- Humidifi Jupiter SDK
- Whirlpool SDK

---

## Error Types

### Jupiter-Specific Errors
- `Empty route`
- `Slippage tolerance exceeded`
- `Invalid calculation`
- `Missing platform fee account`
- `Not enough percent to 100`
- `Token input index is invalid`
- `Token output index is invalid`
- `Not Enough Account keys`
- `Non zero minimum out amount not supported`
- `Invalid route plan`
- `Invalid referral authority`
- `Token account doesn't match the ledger`
- `Swap not supported`
- `Exact out amount doesn't match`
- `Source mint and destination mint cannot the same`
- `Invalid mint`
- `Bonding curve already completed`

### Whirlpool-Related Errors
- `LiquidityZero`
- `LiquidityOverflow`
- `LiquidityUnderflow`
- `SqrtPriceOutOfBounds`
- `TickNotFound`
- `InvalidTickArraySequence`
- `AmountOutBelowMinimum`
- `AmountInAboveMaximum`
- `PartialFillError`

---

## Binary Structure

| Section | Size | Type |
|---------|------|------|
| .text | 1.2 MB | CODE |
| .rodata | 31 KB | DATA |
| .data.rel.ro | 46 KB | DATA |
| .dynamic | 176 B | DATA |
| .dynsym | 384 B | DATA |
| .dynstr | 223 B | DATA |
| .rel.dyn | 97 KB | DATA |

---

## Files Generated

- `program.so` - Raw eBPF binary (2.8 MB)
- `disassembly/program.asm` - Full disassembly (7.7 MB)
- `disassembly/strings.txt` - Extracted strings (28 KB)
- `disassembly/errors.txt` - Error messages (22 KB)
- `disassembly/sections.txt` - ELF sections
- `disassembly/symbols.txt` - Symbol table

---

## Key Findings

1. **No On-Chain IDL** - Jupiter uses a hybrid approach, not pure Anchor
2. **Massive DEX Integration** - 35+ venues integrated directly
3. **Complex Routing Logic** - Multiple route types for different use cases
4. **Token 2022 Support** - Handles transfer hooks and extensions
5. **Embedded SDKs** - Third-party DEX SDKs compiled into binary
