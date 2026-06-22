# patchpad

> **Work in progress.**
> Early-stage, personal tool.
> Expect breaking changes and missing features.

Enter a Nix derivation's source, make edits, get a `.patch` file.
That's it.

## Problem

Sometimes you need to edit code you don't control.
A third-party package has a bug, a generated file needs tweaking, a dependency needs a patch before upstream merges your fix.
Without a tool, you're cloning repos manually, applying changes by hand, and hoping you can reconstruct what you did later.

Nix has a built-in answer: `patches = [ ./foo.patch ]`.
patchpad is the missing half that produces that patch.

## Usage

```sh
patchpad open <derivation>.drv
```

1. Environment opens with the derivation's source unpacked and editable
2. Make changes
3. Exit the shell
4. `.patch` file is captured automatically

Feed the patch back into your pipeline:

```nix
patches = [ ./foo.patch ];
```

## Status

Pre-alpha.
Core loop not yet implemented.

- [ ] Unpack derivation source into temp environment
- [ ] Spawn editable shell session
- [ ] Capture diff on shell exit
- [ ] Output patch to file or stdout

## Building

Requires Nix with flakes.

```sh
nix build
```

Or with Cargo:

```sh
cargo build
```

## Non-goals

- Not a dev environment manager (use `nix develop`, devenv, devbox)
- Not an overlay manager (wiring the patch back is your job)
- Not a VCS (one session = one patch, no history)
- Not a package manager

## License

See [LICENSE](LICENSE).
