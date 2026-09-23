# Install Helium browser declaratively

## Goal

Install Helium for both Nixie hosts through the user-approved community Nix flake, while keeping the browser profile and policies unmanaged.

## Work units

- [x] Add the immutable community flake input and lock it; pass the input into shared Home Manager GUI modules and install its package once for both hosts.
- [ ] Verify lock provenance, desktop/laptop package inclusion and GUI scope; record evidence and commit the implementation.

## Source and trust decision

- User approved `oxcl/nix-flake-helium-browser` for package-only installation.
- Pin exact revision `31b2af977177d347db89d69fac4fe5c44b852007` (GitHub API reported the commit as unsigned).
- The inspected derivation downloads the official Helium Linux `.deb` version `0.17.2.1` with a fixed Nix SHA-256, then extracts and patches the prebuilt binary; it does not build Helium from source or verify the upstream GPG signature. The Nix flake lock/NAR hash pins the community source content.
- The flake supports `x86_64-linux` and `aarch64-linux`; Nixie targets `x86_64-linux`.
- The official Helium Linux project does not list Nix packaging as officially maintained and warns about unlisted packaging.

## Verification evidence

- `nix flake lock --update-input helium` completed; `flake.lock` pins `31b2af977177d347db89d69fac4fe5c44b852007` with NAR hash `sha256-CB/ZmtlGbdqHZV8yBBVb4kjyDBlZkocMDAbJgy/L2QU=` and follows the root nixpkgs input. Lock comparison found no unrelated inputs changed.
- `nix fmt -- --check flake.nix modules/home-manager.nix home/gui/default.nix home/gui/helium.nix` — passed after formatting `modules/home-manager.nix`.
- Scoped `git diff --check` — passed.
- Impure path-flake evaluations via `builtins.getFlake ("path:" + builtins.getEnv "PWD")` passed on desktop and laptop: exactly one `helium-0.17.2.1`, supported on `x86_64-linux`, matching the pinned flake package output.
- Initial formatter check failed only because `modules/home-manager.nix` needed formatting; corrected and rechecked. Initial package eval had an expression interpolation error producing `packages..default`; corrected to literal `"x86_64-linux"` and both host evaluations passed. Nix warned about deprecated `system` alias in the package metadata.
- Native `gentle_review assess` returned `unassessable` because its command returned empty output (RDD off); writer self-check and independent read-only verification passed.
- No NixOS build/test/switch, package build, installation, profile/policy changes, or activation was run.

## Boundaries

- Install only the community flake package via the shared `home/gui` layer; pass the flake input through `home-manager.extraSpecialArgs`.
- Set `inputs.helium.inputs.nixpkgs.follows = "nixpkgs"` to reuse Nixie's pinned package set.
- Do not import the third-party NixOS/Home Manager policy module; do not set browser flags, policies, default-browser associations, or profile files.
- Do not modify `home/gui/hypr` or other browser behavior.
- Preserve unrelated dirty changes in `AGENTS.md`, `modules/`, `odd/tasks/host-module-organization.md`, and `home/core/packages.nix`; only stage/commit the exact Helium implementation and task evidence paths.
- Do not activate the system or run `nixos-rebuild build/test/switch`.
