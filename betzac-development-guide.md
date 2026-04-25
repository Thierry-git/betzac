# Betza Notation Compiler — Project Guide

## Context & Goal

This document guides the conception and implementation of a **Betza notation compiler** targeting a structured move-descriptor IR (Intermediate Representation). The end goal is a system that can be embedded into a Taikyoku Shogi web application, where compiled piece definitions are evaluated against live board state.

The compilation pipeline mirrors classical compiler design:

```
source string → tokens → AST → semantic analysis → IR → runtime evaluator
```

The IR is the shipped artifact. A separate runtime interprets it against board state. This design cleanly separates geometric movement (Betza's domain) from game rules (check, royalty, drops, etc.).

---

## Phase 0 — Nail Down Your Betza Dialect

Before writing any code, document the exact variant of Betza you are implementing. Betza notation has no single authoritative standard. Pick one and treat it as your language specification.

**Recommended starting point:** Ralph Betza's original notation, extended with the Chess Variant Pages wiki additions.

Things to specify explicitly:

- Which **atom letters** are supported (`W`, `F`, `N`, `A`, `D`, `K`, `Q`, `B`, `R`, …)
- Which **direction modifiers** are supported (`f`, `b`, `s`, `l`, `r`, `v`, `h`, …)
- Which **move-type modifiers** are supported (`m`, `c`, `o`, `i`, `n`, `j`, …)
- How **numeric ranges** are expressed (`2`, `3`, `n` for unlimited, …)
- How **grouping and sequencing** work (parentheses, concatenation semantics)
- Any **macro expansions** you want to support (`Q = BW`, etc.)

Write this as a small reference document alongside your code. Taikyoku Shogi has ~200+ piece types; you will hit edge cases, and having a written spec to arbitrate them is invaluable.

---

## Phase 1 — Lexer

**Input:** raw Betza string (e.g., `fFifmnDifmnNifmnA`)  
**Output:** flat list of tokens with type and value

### Token types to define

| Category | Examples |
|---|---|
| Atom | `W`, `F`, `N`, `A`, `D`, `K`, `Q`, `B`, `R` |
| Direction modifier | `f`, `b`, `s`, `l`, `r`, `v`, `h` |
| Move-type modifier | `m`, `c`, `o`, `i`, `n`, `j` |
| Range | `2`, `3`, any digit sequence; `n` for unlimited |
| Grouping | `(`, `)` |

### Notes

- Betza is mostly context-sensitive at the character level — the same letter can be an atom or a modifier depending on position. Handle this carefully. The lexer may need a small amount of lookahead or state, or you can defer disambiguation to the parser.
- Consider whether your lexer should emit a single `MODIFIER` token type with a value, or distinct token types per modifier. Distinct types make the grammar more explicit; a single type with value makes the lexer simpler. Either works.

---

## Phase 2 — Parser & AST

**Input:** token stream  
**Output:** Abstract Syntax Tree

### Suggested grammar (informal)

```
moveset     := atom_expr+
atom_expr   := modifier* atom range?
modifier    := direction_mod | movetype_mod
direction_mod := 'f' | 'b' | 's' | 'l' | 'r' | 'v' | 'h' | ...
movetype_mod  := 'm' | 'c' | 'o' | 'i' | 'n' | 'j' | ...
atom        := 'W' | 'F' | 'N' | 'A' | 'D' | ...
range       := digit+ | 'n'
```

A recursive descent parser is more than sufficient. Betza is not deeply nested, so you will not need complex precedence handling.

### AST node types

```
MovesetNode
  children: AtomExprNode[]

AtomExprNode
  atom: AtomNode
  directionModifiers: DirectionModNode[]
  moveTypeModifiers: MoveTypeModNode[]
  range: RangeNode

AtomNode
  symbol: string        -- e.g. "W", "F", "N"

RangeNode
  kind: Exactly | UpTo | Unlimited
  value?: number        -- present for Exactly and UpTo
```

---

## Phase 3 — Semantic Analysis

**Input:** AST  
**Output:** annotated/transformed AST, or error list

This phase resolves *meaning* before the IR is generated. The more you resolve here, the dumber and more mechanical your IR and any future lowering passes become.

### Key responsibilities

**1. Direction resolution**  
Convert raw direction letters into normalized geometric directions. Do not let raw Betza letters survive into the IR.

```
"f"  → FORWARD  (relative to piece color/orientation)
"b"  → BACKWARD
"s"  → SIDEWAYS (both left and right)
"fs" → {FORWARD, LEFT, RIGHT}
```

Decide here how to handle color-relative directions (`f`/`b`) versus absolute board directions. This decision ripples into the runtime, so make it explicit.

**2. Modifier scoping**  
Betza modifiers apply to the atom that immediately follows them. Verify this is consistently modeled in the AST. Emit errors for modifier sequences that are syntactically valid but semantically contradictory (e.g., `m` and `c` may interact with `o` in non-obvious ways depending on your dialect spec).

**3. Range normalization**  
Resolve the `RangeNode` to your canonical sum type:
```
Range::Exactly(n)
Range::UpTo(n)
Range::Unlimited
```
Default range (no range token present) should be resolved here to its implicit value per atom — for most atoms this is `Exactly(1)`, for sliders it may differ.

**4. Atom expansion (optional)**  
If you support macro atoms (`Q`, `K`, `B`, `R`), expand them to their primitive equivalents here. This simplifies the IR by reducing the number of atom types the runtime needs to handle.

**5. Error collection**  
Collect all semantic errors before failing, so you can report multiple issues at once. Useful during development when stress-testing with Taikyoku piece definitions.

---

## Phase 4 — IR Generation

**Input:** semantically analyzed AST  
**Output:** move-descriptor IR

This is the **shipped artifact** — the compiled form of a piece's movement rules. It should be serializable (JSON is fine), inspectable, and independent of any specific board implementation.

### IR schema

```
MoveSet
  atoms: MoveAtom[]

MoveAtom
  baseAtom: AtomKind          -- W, F, N, A, D, ...  (enum, not string)
  directions: Direction[]     -- resolved geometric directions (enum values)
  range: Range                -- Exactly(n) | UpTo(n) | Unlimited
  moveFlags: MoveFlag[]       -- CanMove, CanCapture, MustCapture, ...
  guards: Guard[]             -- conditions checked at runtime

Guard
  kind: GuardKind             -- InitialMoveOnly, HasNotMoved, ...
  (extend as needed per dialect)
```

### The key design test

Look at each IR node and ask: *does this node require interpretation, or just execution?*

- If the runtime has to decide what a node **means** → the meaning should have been resolved in semantic analysis.
- If the runtime just has to **carry out** what the node says → you're in good shape.

### What does NOT belong in the IR

- Raw Betza source strings
- Unresolved direction letters
- Modifier nesting (modifiers are flattened onto atoms in semantic analysis)
- Anything that requires knowing the board state to interpret (that belongs in the runtime)

---

## Phase 5 — Runtime Evaluator

**Input:** compiled `MoveSet` IR + board state + query square  
**Output:** set of reachable target squares (geometrically legal moves)

The runtime is a separate concern from the compiler. Keep this boundary clean.

### Responsibilities

- Iterate over `MoveAtom` entries in the `MoveSet`
- For each atom, iterate over its `directions`
- Apply `range` to determine how far to extend in each direction
- Check `moveFlags` to determine whether each candidate square is reachable (empty vs. occupied vs. capturable)
- Evaluate `guards` against the current board state (e.g., has this piece moved?)

### What does NOT belong in the runtime

- Legality checking (check, pins, etc.) — that's the game engine's job
- Royal piece logic — game engine
- Drop rules — game engine
- Promotion — game engine

The runtime answers exactly one question: *"given this piece's movement rules and this board state, which squares can it geometrically reach?"* Everything else is layered on top by the game engine.

---

## Phase 6 — Testing Strategy

Test each phase independently before integrating.

### Lexer/parser
Round-trip test: parse a Betza string, pretty-print the AST back to a string, compare. Use well-known piece definitions as fixtures.

### Semantic analysis
Test direction resolution, range normalization, and modifier scoping in isolation with unit tests.

### IR correctness
Compile well-known pieces and assert on the IR structure:
- `W` → 4 directions, range 1, CanMove + CanCapture
- `F` → 4 diagonal directions, range 1, CanMove + CanCapture
- `N` → 8 knight-jump vectors, fixed range, CanMove + CanCapture
- `B` → 4 diagonal directions, Unlimited range
- `Q` → 8 directions, Unlimited range (if you expand macros)

### Runtime
Given a known IR and a known board state, assert on the exact set of reachable squares. Use simple board positions where the answer is manually verifiable.

### Regression suite
As you add Taikyoku piece definitions, any piece that once produced a wrong move set becomes a permanent regression test.

---

## Keeping Option 3 (Bytecode) Available

If you later want to lower the IR to bytecode for a custom VM, the IR described above is already designed to make that mechanical. The additional work would be:

1. **Instruction set design** — define your VM's opcodes (`PUSH_DIR`, `SET_RANGE`, `ADD_GUARD`, `EMIT_MOVES`, …)
2. **Lowering pass** — an IR visitor that emits instructions; straightforward because the IR is already flat and resolved
3. **VM implementation** — replaces the tree-walking runtime evaluator

Nothing in phases 1–4 would need to change. The IR is the stable interface between the compiler and the execution layer, regardless of whether that layer is a tree-walker or a bytecode VM.

---

## Separation of Concerns Summary

| Layer | Knows about | Does not know about |
|---|---|---|
| Lexer/Parser | Betza syntax | Semantics, board |
| Semantic analysis | Betza semantics, geometry | Board state, game rules |
| IR | Resolved movement structure | Board state, game rules |
| Runtime evaluator | IR + board geometry | Check, royalty, drops, promotion |
| Game engine | Legal moves, game rules | Betza, IR internals |

Keeping these layers honest is the most important architectural discipline in this project. Any time a concern from a lower layer leaks upward (or a higher layer's knowledge leaks downward), it will cost you later.

---

## Suggested Implementation Order

1. Write your dialect spec document
2. Lexer + parser for a small subset (just `W`, `F`, `N` with no modifiers)
3. IR schema design + basic runtime evaluator — get moves working end-to-end for those three pieces
4. Expand lexer/parser to full grammar
5. Semantic analysis phase
6. Full IR generation
7. Expand runtime for all direction/range/flag combinations
8. Guards (`InitialMoveOnly`, etc.)
9. Stress-test with Taikyoku piece definitions
