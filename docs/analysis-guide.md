# Solana Program Analysis Guide

This guide explains how to analyze Solana programs, understand their structure, and extract useful information.

## Understanding Solana Programs

Solana programs are compiled to **eBPF (extended Berkeley Packet Filter)** bytecode, stored in ELF format. They run on the Solana Virtual Machine (SVM).

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Program** | Executable code deployed on-chain |
| **Account** | Data storage on Solana (programs are stateless) |
| **Instruction** | Entry point into program logic |
| **CPI** | Cross-Program Invocation - calling other programs |
| **PDA** | Program Derived Address - deterministic account addresses |

## Analysis Workflow

### 1. Download the Program Binary

```bash
solana program dump <PROGRAM_ID> program.so --url mainnet-beta
```

This downloads the raw BPF bytecode from the chain.

### 2. Basic Binary Analysis

```bash
# File type and architecture
file program.so
# Output: ELF 64-bit LSB shared object, eBPF, version 1 (SYSV), dynamically linked, stripped

# File size
ls -lh program.so

# Extract readable strings
strings program.so > strings.txt

# Look for instruction names
strings program.so | grep "Instruction:"
```

### 3. Check for Anchor IDL

Anchor programs store their IDL (Interface Definition Language) on-chain:

```bash
anchor idl fetch <PROGRAM_ID> --provider.cluster mainnet
```

The IDL contains:
- Instruction definitions
- Account structures
- Error codes
- Type definitions

### 4. Disassemble the Binary

Use LLVM tools to disassemble eBPF:

```bash
llvm-objdump -d program.so > disassembly.asm
```

### 5. Extract Program Structure

From strings, you can often find:
- Source file paths (reveals module structure)
- Error messages
- Account/instruction names
- Integrated protocols

## Identifying Program Type

### Anchor Programs

Look for:
- `anchor:idl` in strings
- IDL fetch succeeds
- `AnchorError` in error messages
- Standard discriminator pattern (8-byte instruction prefix)

### Native Programs

Look for:
- No IDL available
- Custom serialization patterns
- Direct `entrypoint!` macro usage

## Understanding the Disassembly

### eBPF Registers

| Register | Purpose |
|----------|---------|
| `r0` | Return value |
| `r1-r5` | Function arguments |
| `r6-r9` | Callee-saved |
| `r10` | Frame pointer (read-only) |

### Common Patterns

**Function Call:**
```asm
call <offset>
```

**Memory Access:**
```asm
r2 = *(u64 *)(r1 + 0x8)   # Load 64-bit value
*(u64 *)(r1 + 0x0) = r2   # Store 64-bit value
```

**Conditional Branch:**
```asm
if r1 == 0x0 goto +0x10   # Jump if equal
if r1 s> 0x5 goto +0x1d   # Jump if signed greater
```

## Extracting Useful Information

### From Strings

```bash
# Error messages
strings program.so | grep -iE "error|failed|invalid"

# Source paths (reveals structure)
strings program.so | grep "src/"

# Integrated protocols
strings program.so | grep -iE "raydium|jupiter|orca|meteora"
```

### From IDL

```bash
# List instructions
jq '.instructions[].name' idl.json

# List accounts
jq '.accounts[].name' idl.json

# List errors
jq '.errors[] | "\(.code): \(.name)"' idl.json

# Get instruction details
jq '.instructions[] | select(.name == "swap")' idl.json
```

## Security Analysis

### Look For

1. **Access Control**: Check for signer verification
2. **Account Validation**: PDA derivation, owner checks
3. **Arithmetic**: Overflow protection (checked_add, etc.)
4. **Reentrancy**: CPI patterns
5. **Error Handling**: Proper error propagation

### Red Flags in Strings

```bash
# Unchecked operations
strings program.so | grep -i "unchecked"

# Unsafe patterns
strings program.so | grep -i "unsafe"

# Panic locations
strings program.so | grep "panic"
```

## Common Integrations

When analyzing DEX aggregators or DeFi programs, look for integrations:

| Protocol | Identifier |
|----------|------------|
| Raydium AMM | `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8` |
| Raydium CLMM | `CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK` |
| Orca Whirlpools | `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc` |
| Meteora DLMM | `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo` |
| Phoenix | `PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY` |

## Tools Reference

| Tool | Installation | Purpose |
|------|--------------|---------|
| `solana` | `brew install solana` | CLI for Solana operations |
| `anchor` | `cargo install anchor-cli` | Anchor framework tools |
| `llvm-objdump` | `brew install llvm` | Disassembler |
| `jq` | `brew install jq` | JSON processing |
| `strings` | Built-in | Extract printable strings |

## Resources

- [Solana Program Library](https://github.com/solana-labs/solana-program-library)
- [Anchor Documentation](https://www.anchor-lang.com/)
- [eBPF Instruction Set](https://www.kernel.org/doc/html/latest/bpf/instruction-set.html)
- [Solana Cookbook](https://solanacookbook.com/)
