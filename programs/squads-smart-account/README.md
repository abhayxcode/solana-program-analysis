# Squads Smart Account Program

**Program ID:** `SMRTzfY6DfH5ik3TKiyLFfXexV8uSG3d2UksSCYdunG`
**Website:** https://squads.so
**Source Code:** https://github.com/squads-protocol/smart-account-program
**Security:** security@sqds.io, contact@osec.io
**Auditors:** OtterSec, Certora
**Framework:** Anchor
**Binary Size:** 1.6 MB

## Overview

Squads Smart Account Program is the core on-chain program powering **Squads Protocol** — the leading multisig and smart account infrastructure on Solana. It provides programmable multi-signature wallets with proposal-based governance, spending limits, batched transactions, policy enforcement, and time locks.

Smart accounts act as on-chain vaults controlled by multiple signers who must collectively approve transactions before execution. This is the successor to the earlier Squads Multisig (v3/v4) programs.

## Architecture

### Core Flow

```
Signers → CreateSmartAccount (define threshold, signers, permissions)
       → CreateTransaction (define what to execute)
       → CreateProposal → ActivateProposal
       → ApproveProposal (each signer votes)
       → ExecuteTransaction (once threshold reached)
```

### Key Concepts

- **Smart Account**: A PDA-owned vault with configurable signers, threshold, and time lock
- **Proposal**: A voting record attached to a transaction — signers approve, reject, or cancel
- **Transaction**: An arbitrary Solana transaction message to be executed via CPI from the smart account PDA
- **Batch**: Groups multiple transactions under one proposal for sequential execution
- **Spending Limit**: Pre-approved transfer allowance that bypasses full multisig voting
- **Policy**: Constraints that govern what a smart account can do (program interactions, fund transfers, settings changes)
- **Settings Authority**: An optional authority that can modify smart account settings without proposals
- **Time Lock**: Mandatory delay between proposal approval and execution (up to 90 days)

## Instructions (46)

### Program Administration (4)
| Instruction | Description |
|---|---|
| `InitializeProgramConfig` | Initialize the global program configuration |
| `SetProgramConfigAuthority` | Set the program config authority |
| `SetProgramConfigSmartAccountCreationFee` | Set the fee for creating smart accounts |
| `SetProgramConfigTreasury` | Set the program treasury address |

### Smart Account Management (1)
| Instruction | Description |
|---|---|
| `CreateSmartAccount` | Create a new multisig smart account |

### Settings Authority Operations (9)
| Instruction | Description |
|---|---|
| `AddSignerAsAuthority` | Add a signer via settings authority |
| `RemoveSignerAsAuthority` | Remove a signer via settings authority |
| `SetTimeLockAsAuthority` | Set time lock duration via settings authority |
| `ChangeThresholdAsAuthority` | Change approval threshold via settings authority |
| `SetNewSettingsAuthorityAsAuthority` | Transfer settings authority |
| `SetArchivalAuthorityAsAuthority` | Set archival authority |
| `AddSpendingLimitAsAuthority` | Add a spending limit via settings authority |
| `RemoveSpendingLimitAsAuthority` | Remove a spending limit via settings authority |
| `CloseSettingsTransaction` | Close settings transaction, reclaim rent |

### Settings Transactions (3)
| Instruction | Description |
|---|---|
| `CreateSettingsTransaction` | Create a transaction to change settings |
| `ExecuteSettingsTransaction` | Execute an approved settings change |
| `ExecuteSettingsTransactionSync` | Execute settings change synchronously |

### Transaction Lifecycle (10)
| Instruction | Description |
|---|---|
| `CreateTransaction` | Create a new transaction |
| `CreateTransactionBuffer` | Create buffer for large transaction messages |
| `ExtendTransactionBuffer` | Append data to buffer |
| `CloseTransactionBuffer` | Close buffer, reclaim rent |
| `CreateTransactionFromBuffer` | Finalize transaction from buffer |
| `ExecuteTransaction` | Execute approved transaction via CPI |
| `ExecuteTransactionSync` | Execute synchronously (deprecated) |
| `ExecuteTransactionSyncV2` | Execute synchronously with policy support |
| `CloseTransaction` | Close transaction, reclaim rent |
| `CloseEmptyPolicyTransaction` | Close empty policy transaction |

### Batch Operations (5)
| Instruction | Description |
|---|---|
| `CreateBatch` | Create a batch for grouping transactions |
| `AddTransactionToBatch` | Add transaction to batch |
| `ExecuteBatchTransaction` | Execute one transaction in a batch |
| `CloseBatchTransaction` | Close batch transaction |
| `CloseBatch` | Close entire batch |

### Proposal Governance (5)
| Instruction | Description |
|---|---|
| `CreateProposal` | Create a proposal for a transaction |
| `ActivateProposal` | Activate proposal for voting |
| `ApproveProposal` | Vote to approve |
| `RejectProposal` | Vote to reject |
| `CancelProposal` | Cancel an active proposal |

### Spending Limits (1)
| Instruction | Description |
|---|---|
| `UseSpendingLimit` | Transfer tokens using a pre-approved spending limit |

### Utility (1)
| Instruction | Description |
|---|---|
| `LogEvent` | Emit a program event |

### IDL Management (7)
| Instruction | Description |
|---|---|
| `IdlCreateAccount` | Create IDL account |
| `IdlResizeAccount` | Resize IDL account |
| `IdlCloseAccount` | Close IDL account |
| `IdlCreateBuffer` | Create IDL upload buffer |
| `IdlWrite` | Write IDL data |
| `IdlSetAuthority` | Set IDL authority |
| `IdlSetBuffer` | Set IDL from buffer |

## Account Types (11)

| Account | Seed | Description |
|---|---|---|
| `SmartAccount` | `smart_account` | Main multisig vault with signers, threshold, time lock |
| `Proposal` | `proposal` | Voting record tracking approvals/rejections |
| `Transaction` | `transaction` | Transaction message to execute via CPI |
| `TransactionBuffer` | `transaction_buffer` | Buffer for large messages (max 4000 bytes) |
| `Batch` | `batch` | Groups transactions under one proposal |
| `BatchTransaction` | `batch_transaction` | Individual transaction within a batch |
| `SpendingLimit` | `spending_limit` | Pre-approved transfer allowance |
| `ProgramConfig` | `program_config` | Global program configuration |
| `Settings` | `settings` | Smart account signer/permission settings |
| `SettingsTransaction` | `settings_transaction` | Settings modification transaction |
| `Policy` | `policy` | Constraints for program interactions |

## Policy Engine

The program includes a sophisticated policy engine with 4 policy types:

### 1. Spending Limit Policy
Controls token transfers with:
- Per-use limits, per-period limits
- Cadence/period configuration (one-time, custom periods)
- Start time, expiration
- Overflow accumulation
- Exact quantity constraints
- Destination restrictions per mint

### 2. Program Interaction Policy
Governs CPI calls from the smart account:
- Program ID whitelisting
- Account constraints
- Instruction data validation (numeric values, byte sequences)
- Instruction count limits (max 20 constraints)
- Spending limits per interaction (max 10)
- Lamport and token allowance tracking
- Template hooks with hook authority

### 3. Internal Fund Transfer Policy
Controls transfers between accounts within the smart account:
- Source/destination account index restrictions
- Mint whitelisting
- Amount minimums
- Duplicate mint prevention

### 4. Settings Change Policy
Governs modifications to smart account settings:
- Allowed signer additions/removals
- Signer permission constraints
- Time lock modification rules
- Action matching and deduplication

## Error Codes (100)

The program defines 100 custom error codes. Key categories:

**Signer Errors**: AccountNotEmpty, DuplicateSigner, EmptySigners, TooManySigners, InvalidThreshold, NotASigner, RemoveLastSigner, NoProposers, NoExecutors, NoVoters

**Authorization Errors**: Unauthorized, InsufficientAggregatePermissions, InsufficientVotePermissions, MissingSignature, UnknownPermission, ProtectedAccount

**Proposal Errors**: StaleProposal, InvalidProposalStatus, AlreadyApproved, AlreadyRejected, AlreadyCancelled, ThresholdNotReached, TimeLockNotReleased

**Spending Limit Errors**: SpendingLimitExceeded, SpendingLimitNotActive, SpendingLimitExpired, SpendingLimitInsufficientRemainingAmount, 16 invariant violations

**Policy Errors**: 20 ProgramInteraction violations, 6 InternalFundTransfer invariants, 11 SettingsChange violations, PolicyNotActiveYet, PolicyExpirationViolation

## Binary Structure

| Section | Size | Type |
|---|---|---|
| `.text` | 1.4 MB | Executable code |
| `.rodata` | 33 KB | Read-only data |
| `.data.rel.ro` | 13 KB | Relocatable data |
| `.dynamic` | 176 B | Dynamic linking |
| `.dynsym` | 408 B | Dynamic symbols |
| `.dynstr` | 248 B | Dynamic strings |
| `.rel.dyn` | 99 KB | Relocations |

## Source Structure (from binary paths)

```
programs/squads_smart_account_program/src/
├── lib.rs                          # Program entrypoint
├── allocator.rs                    # Memory allocator
├── events/mod.rs                   # Event definitions
├── instructions/
│   ├── activate_proposal.rs
│   ├── authority_settings_transaction_execute.rs
│   ├── authority_spending_limit_add.rs
│   ├── authority_spending_limit_remove.rs
│   ├── batch_add_transaction.rs
│   ├── batch_create.rs
│   ├── batch_execute_transaction.rs
│   ├── log_event.rs
│   ├── program_config_change.rs
│   ├── program_config_init.rs
│   ├── proposal_create.rs
│   ├── proposal_vote.rs
│   ├── settings_transaction_create.rs
│   ├── settings_transaction_execute.rs
│   ├── settings_transaction_sync.rs
│   ├── smart_account_create.rs
│   ├── transaction_buffer_create.rs
│   ├── transaction_buffer_extend.rs
│   ├── transaction_close.rs
│   ├── transaction_create.rs
│   ├── transaction_create_from_buffer.rs
│   ├── transaction_execute.rs
│   ├── transaction_execute_sync.rs
│   ├── transaction_execute_sync_legacy.rs
│   └── use_spending_limit.rs
├── interface/
│   ├── consensus.rs
│   └── consensus_trait.rs
├── state/
│   ├── batch.rs
│   ├── legacy_transaction.rs
│   ├── program_config.rs
│   ├── proposal.rs
│   ├── settings.rs
│   ├── settings_transaction.rs
│   ├── spending_limit.rs
│   ├── transaction.rs
│   ├── transaction_buffer.rs
│   └── policies/
│       ├── implementations/
│       │   ├── internal_fund_transfer.rs
│       │   ├── program_interaction.rs
│       │   ├── settings_change.rs
│       │   └── spending_limit_policy.rs
│       ├── policy_core/
│       │   ├── payloads.rs
│       │   └── policy.rs
│       └── utils/
│           ├── account_tracking.rs
│           └── spending_limit_v2.rs
└── utils/
    ├── context_validation.rs
    ├── ephemeral_signers.rs
    ├── executable_transaction_message.rs
    ├── synchronous_transaction_message.rs
    └── system.rs
```

## Key Account Contexts (from binary strings)

| Account Name | Description |
|---|---|
| `signer` | Transaction signer |
| `rent_payer` | Pays rent for new accounts |
| `settings_authority` | Authority for settings changes |
| `system_program` | Solana system program |
| `rent_collector` | Receives rent from closed accounts |
| `creator` | Creator of proposals/transactions |
| `log_authority` | Authority for log events |
| `authority` | General authority account |
| `initializer` | Program config initializer |
| `consensus_account` | Settings or policy account for consensus |
| `transaction_buffer` | Buffer for large transaction messages |
| `smart_account_token_account` | Token account owned by smart account |
| `destination_token_account` | Destination for token transfers |
| `token_program` | SPL Token program |
| `mint` | Token mint |
| `empty_policy` | Empty policy for closing |
| `ephemeral_signer` | PDA-derived ephemeral signer |

## Syscalls Used

- `sol_log_` — Logging
- `sol_memcmp_` / `sol_memcpy_` / `sol_memset_` / `sol_memmove_` — Memory operations
- `sol_try_find_program_address` / `sol_create_program_address` — PDA derivation
- `sol_sha256` — Hashing (for buffer verification)
- `sol_log_pubkey` — Pubkey logging
- `sol_invoke_signed_rust` — CPI execution
- `sol_get_clock_sysvar` / `sol_get_rent_sysvar` — Sysvar access

## Analysis Files

| File | Description |
|---|---|
| `program.so` | 1.6 MB eBPF binary |
| `idl.json` | Empty (IDL not fetched on-chain) |
| `metadata.json` | Download metadata |
| `disassembly/program.asm` | 9.5 MB full disassembly (179,588 lines) |
| `disassembly/sections.txt` | ELF section headers |
| `disassembly/symbols.txt` | Symbol table (stripped) |
| `disassembly/strings.txt` | 917 extracted strings |
| `disassembly/errors.txt` | Error messages |
| `analysis/instructions.json` | 46 instructions with categories |
| `analysis/instruction_names.txt` | Instruction name list |
| `analysis/accounts.json` | 11 account types |
| `analysis/errors.json` | 100 error codes with messages |
| `analysis/source_files.txt` | 52 source files from binary paths |
| `analysis/summary.json` | Program metadata summary |
