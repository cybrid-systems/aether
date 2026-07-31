# Aether

**Self-evolving Agent closed-loops on Aura.**

Aether is the first concrete span project of [Aura Unify](https://github.com/cybrid-systems/aura).
It focuses on the highest-leverage semantic dimensions:

- **Reflection & Safe Mutation** (Dimension 1)
- **Agent & Orchestration** (Dimension 2)

The goal is to demonstrate that a single Aura-native space can densely cover
long-running, self-modifying agent systems with measurable escape rates.

> Aura gives AI a chance to span the high-dimensional semantic space of software.
> Aether is the first real attempt to walk that path.

## Why Aether?

In the Aura Unify vision, different programming languages currently live in
fragmented semantic subspaces. Communication between them is lossy.
Aura attempts to provide an approximately isomorphic base that LLMs can
navigate and mutate safely.

Aether tests the most important claim first:

> Can we build real self-evolving Agent closed-loops that stay mostly inside
> pure Aura, with controlled, observable, and reversible mutations?

If this dimension cannot achieve low escape rates, the broader Unify thesis
is significantly weakened.

## Core Loop

The canonical closed loop we are building:

```
Observe  →  Decide  →  Safe Mutation  →  Verify  →  Rollback (if needed)  →  Observe
```

Key properties we care about:

- Mutation stays inside typed / boundary-guarded regions
- Full observability of every mutation (operator, target, outcome)
- Atomic batch + safe yield support
- Easy rollback to a previous consistent state
- Minimal escape to external languages or services for the core logic

## Project Structure (planned)

```
aether/
├── README.md
├── LICENSE
├── prompts/
│   └── GROK.md          # Living prompt for continued generation
├── lib/
│   └── ...              # Aura modules for the closed loop
├── examples/
│   └── ...              # Runnable closed-loop demos
└── notes/
    └── escape-log.md    # Record of every necessary escape
```

## Relationship to Aura

- Built on top of [Aura](https://github.com/cybrid-systems/aura)
- Uses Aura’s `agent`, `mutate`, `orchestrator`, `query`, `hot-update`, `stats`
  and related stdlib surfaces
- Serves as an empirical testbed for the denseness of `V_A` in the
  agent + mutation subspace

## License

Apache License 2.0 (same as Aura)

## Status

Early construction. The first concrete target is a minimal but complete
**self-evolving Agent closed-loop** that can:

1. Observe its own performance / errors
2. Decide on a code-level change
3. Apply the change under mutation safety guards
4. Verify the result
5. Roll back cleanly if verification fails

Contributions and experiments welcome once the initial skeleton lands.
