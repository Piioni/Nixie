# Safe, non-activating checks for this working tree.

default:
    @just --list

# Show outputs from this directory, including untracked work.
show-working:
    nix flake show --no-write-lock-file path:.

# Inspect only the selected display manager command; this is not a host check or build.
inspect-login host:
    #!/usr/bin/env bash
    set -euo pipefail
    host={{ quote(host) }}
    case "$host" in
      desktop|laptop) ;;
      *) echo "Supported hosts: desktop, laptop" >&2; exit 2 ;;
    esac
    nix eval --no-write-lock-file --raw "path:.#nixosConfigurations.$host.config.services.displayManager.generic.execCmd"

# Compatibility aliases for the limited display-manager inspection.
check-desktop:
    just inspect-login desktop

check-laptop:
    just inspect-login laptop

# Build one Home Manager activation package without activating it.
hm-build host:
    #!/usr/bin/env bash
    set -euo pipefail
    host={{ quote(host) }}
    case "$host" in
      desktop|laptop) ;;
      *) echo "Supported hosts: desktop, laptop" >&2; exit 2 ;;
    esac
    username=$(nix eval --impure --no-write-lock-file --raw --expr '(import ./vars).username')
    NIXPKGS_ALLOW_UNFREE=1 nix build --impure --no-write-lock-file "path:.#nixosConfigurations.$host.config.home-manager.users.$username.home.activationPackage" --no-link

# Build a system closure only after its generated hardware file exists.
system-build host:
    #!/usr/bin/env bash
    set -euo pipefail
    host={{ quote(host) }}
    case "$host" in
      desktop|laptop) ;;
      *) echo "Supported hosts: desktop, laptop" >&2; exit 2 ;;
    esac
    hardware="hosts/$host/hardware-configuration.nix"
    if [ ! -f "$hardware" ]; then
      echo "Cannot build $host: generate $hardware first." >&2
      exit 1
    fi
    nix build --no-write-lock-file "path:.#nixosConfigurations.$host.config.system.build.toplevel" --no-link

# Format one explicit Nix source file outside references/.
fmt file:
    #!/usr/bin/env bash
    set -euo pipefail
    file={{ quote(file) }}
    repo_root=$(realpath -e -- .)
    references_root=$(realpath -e -- "$repo_root/references")
    target=$(realpath -e -- "$file") || { echo "File not found: $file" >&2; exit 2; }
    logical=$(realpath -ms -- "$file")
    [ "$logical" = "$target" ] || { echo "Symlinks are not accepted." >&2; exit 2; }
    [ -f "$target" ] || { echo "Pass a regular .nix file." >&2; exit 2; }
    case "$target" in
      "$repo_root"/*.nix) ;;
      *) echo "Pass a .nix file inside this repository." >&2; exit 2 ;;
    esac
    case "$target" in
      "$references_root"|"$references_root"/*) echo "Reference files are read-only examples." >&2; exit 2 ;;
    esac
    nix fmt -- "$target"

# Check formatting for one explicit Nix source file outside references/.
check file:
    #!/usr/bin/env bash
    set -euo pipefail
    file={{ quote(file) }}
    repo_root=$(realpath -e -- .)
    references_root=$(realpath -e -- "$repo_root/references")
    target=$(realpath -e -- "$file") || { echo "File not found: $file" >&2; exit 2; }
    logical=$(realpath -ms -- "$file")
    [ "$logical" = "$target" ] || { echo "Symlinks are not accepted." >&2; exit 2; }
    [ -f "$target" ] || { echo "Pass a regular .nix file." >&2; exit 2; }
    case "$target" in
      "$repo_root"/*.nix) ;;
      *) echo "Pass a .nix file inside this repository." >&2; exit 2 ;;
    esac
    case "$target" in
      "$references_root"|"$references_root"/*) echo "Reference files are read-only examples." >&2; exit 2 ;;
    esac
    nix fmt -- --check "$target"

# Format every tracked project Nix file; never runs automatically.
fmt-tracked:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "$(git rev-parse --show-toplevel)"
    while IFS= read -r -d '' file; do
      case "$file" in
        references/*) continue ;;
      esac
      just fmt "$file"
    done < <(git ls-files -z -- '*.nix')

# Check every tracked project Nix file; never runs automatically.
check-tracked:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "$(git rev-parse --show-toplevel)"
    while IFS= read -r -d '' file; do
      case "$file" in
        references/*) continue ;;
      esac
      just check "$file"
    done < <(git ls-files -z -- '*.nix')

# Update one floating root flake input without building, switching, or committing.
update-one input:
    #!/usr/bin/env bash
    set -euo pipefail
    input={{ quote(input) }}
    case "$input" in
      nixpkgs|nix-gaming|disko|home-manager|noctalia|noctalia-protonvpn) ;;
      *) echo "Floating inputs: nixpkgs, nix-gaming, disko, home-manager, noctalia, noctalia-protonvpn" >&2; exit 2 ;;
    esac
    nix flake update "$input"

# Update all root flake inputs without building, switching, or committing.
update-all:
    nix flake update
