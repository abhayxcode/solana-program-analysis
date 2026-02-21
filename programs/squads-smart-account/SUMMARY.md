# Squads Smart Account Program — Analysis Summary

Generated: 2026-02-12

## Program Info

| Property | Value |
|----------|-------|
| Program ID | `SMRTzfY6DfH5ik3TKiyLFfXexV8uSG3d2UksSCYdunG` |
| Name | Squads Smart Account Program |
| Cluster | mainnet-beta |
| Framework | Anchor |
| Binary Size | 1.6 MB |
| File Type | ELF 64-bit LSB shared object, eBPF, version 1 (SYSV), dynamically linked, stripped |
| Website | https://squads.so |
| Source Code | https://github.com/squads-protocol/smart-account-program |
| Auditors | OtterSec, Certora |
| Security Contact | security@sqds.io |

## Analysis Metrics

| Metric | Count |
|--------|-------|
| Instructions | 46 |
| Account Types | 11 |
| Error Codes | 100 |
| Source Files | 52 |
| Policy Types | 4 |
| Disassembly Lines | 179,588 |
| Strings Extracted | 917 |

## IDL Status

On-chain IDL fetch failed. Analysis performed via binary string extraction and disassembly. The program is built with the Anchor framework (confirmed by Anchor error messages and IDL management instructions in the binary).

## Instructions (46)

### Program Admin (4)
- `InitializeProgramConfig`
- `SetProgramConfigAuthority`
- `SetProgramConfigSmartAccountCreationFee`
- `SetProgramConfigTreasury`

### Smart Account (1)
- `CreateSmartAccount`

### Authority Operations (9)
- `AddSignerAsAuthority`
- `RemoveSignerAsAuthority`
- `SetTimeLockAsAuthority`
- `ChangeThresholdAsAuthority`
- `SetNewSettingsAuthorityAsAuthority`
- `SetArchivalAuthorityAsAuthority`
- `AddSpendingLimitAsAuthority`
- `RemoveSpendingLimitAsAuthority`
- `CloseSettingsTransaction`

### Settings Transactions (3)
- `CreateSettingsTransaction`
- `ExecuteSettingsTransaction`
- `ExecuteSettingsTransactionSync`

### Transaction Lifecycle (10)
- `CreateTransaction`
- `CreateTransactionBuffer`
- `ExtendTransactionBuffer`
- `CloseTransactionBuffer`
- `CreateTransactionFromBuffer`
- `ExecuteTransaction`
- `ExecuteTransactionSync` *(deprecated)*
- `ExecuteTransactionSyncV2`
- `CloseTransaction`
- `CloseEmptyPolicyTransaction`

### Batch Operations (5)
- `CreateBatch`
- `AddTransactionToBatch`
- `ExecuteBatchTransaction`
- `CloseBatchTransaction`
- `CloseBatch`

### Proposal Governance (5)
- `CreateProposal`
- `ActivateProposal`
- `ApproveProposal`
- `RejectProposal`
- `CancelProposal`

### Spending Limits (1)
- `UseSpendingLimit`

### Utility (1)
- `LogEvent`

### IDL Management (7)
- `IdlCreateAccount`, `IdlResizeAccount`, `IdlCloseAccount`
- `IdlCreateBuffer`, `IdlWrite`, `IdlSetAuthority`, `IdlSetBuffer`

## Error Codes (100)

See `analysis/errors.json` for full list with messages. Key categories:

| Category | Count | Examples |
|---|---|---|
| Signer/Auth | 15 | Unauthorized, NotASigner, TooManySigners, MissingSignature |
| Proposal | 8 | StaleProposal, AlreadyApproved, ThresholdNotReached |
| Spending Limit | 20 | SpendingLimitExceeded, 16 invariant violations |
| Program Interaction | 16 | AccountConstraintViolated, ProgramIdMismatch, TooManySpendingLimits |
| Internal Fund Transfer | 6 | SourceAccountIndexNotAllowed, MintNotAllowed |
| Settings Change | 12 | AddSignerViolation, ChangeTimelockViolation, ActionMismatch |
| Policy | 5 | PolicyNotActiveYet, PolicyExpirationViolation |
| General | 18 | InvalidAccount, BatchNotEmpty, FinalBufferHashMismatch |

## Binary Structure

| Section | Size |
|---------|------|
| `.text` | 1.4 MB (executable code) |
| `.rodata` | 33 KB (read-only data) |
| `.data.rel.ro` | 13 KB (relocatable data) |
| `.rel.dyn` | 99 KB (relocations) |
| `.dynamic` | 176 B |
| `.dynsym` | 408 B |
| `.dynstr` | 248 B |

## Files

```
programs/smrt/
├── README.md              # Detailed analysis documentation
├── SUMMARY.md             # This file
├── program.so             # 1.6 MB eBPF binary
├── idl.json               # Empty (not fetched)
├── metadata.json          # Download metadata
├── disassembly/
│   ├── program.asm        # 9.5 MB full disassembly
│   ├── sections.txt       # ELF section headers
│   ├── symbols.txt        # Symbol table (stripped)
│   ├── strings.txt        # 917 extracted strings
│   ├── errors.txt         # Error messages
│   └── instructions.txt   # Instruction hints
└── analysis/
    ├── instructions.json  # 46 instructions with categories
    ├── instruction_names.txt
    ├── accounts.json      # 11 account types
    ├── errors.json        # 100 error codes
    ├── source_files.txt   # 52 source files
    └── summary.json       # Metadata summary
```
