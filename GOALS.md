# patchpad — Goals

## Vision

patchpad creates temporary developer environments rooted at the source of a Nix derivation.
Changes made within the environment are recorded as a standard `.patch` file.
The patch can then be fed back into the Nix pipeline, submitted upstream, or used however the developer needs.

## Problem

Nix pipelines are powerful but immutable.
When you need to edit code in the middle of a pure-nix pipeline — for example, a code-generating derivation whose output you want to tweak — there is no ergonomic way to:

- Enter an editable environment at a specific point in the pipeline
- Capture changes as a reproducible, portable patch
- Feed that patch back into the build graph

Existing tools (devenv, devbox, `nix develop`) solve the "give me a shell with dependencies" problem, not the "give me the source of this derivation to edit and capture my changes" problem.

## Core use case

The primary motivation is editing code in the middle of a pure-nix pipeline:

1. Run `patchpad open <derivation>.drv`
2. An environment opens with the derivation's source unpacked and editable
3. Make changes
4. A `.patch` file is captured when the session ends
5. The patch integrates back into the pipeline via `patches = [ ./foo.patch ]` or an equivalent mechanism

A secondary use case is simplifying the path from "I want to fix something in this package" to a `.patch` file ready to submit upstream or attach to a PR.

## Goals

- Accept any Nix derivation or store path as input
- Provide an editable environment rooted at that derivation's source
- Record all changes as a standard `.patch` file
- Output patch to a local file or stdout; the user controls the destination
- Support configurable output modes: raw patch file, PR submission, overlay snippet
- Integrate cleanly with Nix pipelines (`patches = [ ]` pattern)
- Remain compatible with stacked diffs workflows
- CLI-first interface
- Start as a personal tool and grow toward open-source community adoption

## Non-goals

- **Not a dev environment manager.**
  patchpad is not a replacement for devenv, devbox, or `nix develop`.
  It does not manage dependencies or long-lived environments.
- **Not an overlay manager.**
  patchpad produces a patch.
  Wiring that patch back into a Nix overlay or flake is the user's responsibility.
- **Not a version control system.**
  One session produces one patch.
  patchpad does not maintain a history of changes across sessions.
- **Not a package manager.**
  patchpad does not install or manage packages.

## Open questions

- **Session lifecycle.**
  How and when should the session end and patch capture trigger?
  (explicit command, shell exit, or both — not yet decided)
- **Implementation stack.**
  The tech stack for patchpad itself is not yet decided.
