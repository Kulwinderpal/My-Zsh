#!/usr/bin/env bash
# Installs a set of CLI tools on Linux or macOS (via the native package manager)

set -uo pipefail

# Packages to install. These are the *repo* names, not necessarily the binary names.
PKGS=(fzf ripgrep bat fastfetch zsh git)

# Map repo name -> binary name, so the "already installed?" check works for packages whose binary differs from the package name (ripgrep -> rg).
declare -A BIN=([fzf]=fzf [ripgrep]=rg [bat]=bat [fastfetch]=fastfetch [zsh]=zsh [git]=git)

# Print an error to stderr.
err(){ printf 'Error: %s\n' "$*" >&2; }

# Use sudo only when we're not already root AND sudo actually exists
SUDO=""; [ "$EUID" -ne 0 ] && command -v sudo >/dev/null && SUDO=sudo

# --- Build the list of MISSING packages -------------------------------------
# For each package, check if its binary is on PATH. If not, add it to M.
M=(); for p in "${PKGS[@]}"; do
  [ "$p" = bat ] && command -v batcat >/dev/null 2>&1 && continue
  command -v "${BIN[$p]}" >/dev/null 2>&1 || M+=("$p")
done

# --- Install (only if something is missing) --------------------------------
[ ${#M[@]} -eq 0 ] && echo "All packages already installed." || {
  echo "Installing: ${M[*]}"
  case "$(uname -s)" in
    Darwin)
      # macOS: Homebrew only.
      command -v brew >/dev/null || { err 'Brew is not installed,you can install it with /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'; exit 1; }
      brew update && brew install "${M[@]}" ;;

    Linux)
      # Detect the package manager by which binary is present; first match wins.
      if   command -v apt-get >/dev/null; then
        # Debian / Ubuntu
        $SUDO apt-get update
        # Swap 'bat' -> 'batcat' only if the apt cache has no 'bat' package.
        P=("${M[@]}"); apt-cache show bat >/dev/null 2>&1 || P=("${P[@]/bat/batcat}")
        $SUDO apt-get install -y "${P[@]}"
      elif command -v dnf >/dev/null; then
        # Fedora / RHEL / CentOS (yum intentionally not supported)
        $SUDO dnf makecache && $SUDO dnf install -y "${M[@]}"
      elif command -v pacman >/dev/null; then
        # Arch
        $SUDO pacman -Sy --noconfirm "${M[@]}"
      elif command -v zypper >/dev/null; then
        # openSUSE
        $SUDO zypper refresh && $SUDO zypper install -y "${M[@]}"
      elif command -v apk >/dev/null; then
        # Alpine
        $SUDO apk update && $SUDO apk add "${M[@]}"
      elif command -v xbps-install >/dev/null; then
        # Void Linux
        $SUDO xbps-install -Sy "${M[@]}"
      elif command -v emerge >/dev/null; then
        # Gentoo / Portage: -n == --noreplace, don't re-emerge what's installed
        $SUDO emerge --sync && $SUDO emerge -n "${M[@]}"
      elif command -v nix >/dev/null; then
        # Nix: prefer flakes, fall back to nix-env on older installs
        nix-channel --update 2>/dev/null
        for p in "${M[@]}"; do
          nix profile install "nixpkgs#$p" 2>/dev/null || nix-env -iA "nixpkgs.$p"
        done
      else
        err "No supported package manager detected."; exit 1
      fi ;;
    *)
      err "Unsupported OS: $(uname -s)"; exit 1 ;;
  esac
}

# --- Deploy config files ---------------------------------------------------
echo "Deploying config files..."

# Back up an existing ~/.zshrc (only the most recent backup survives a re-run).
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak

# Downlaods the Config Files
T=$(mktemp); curl -fsSL https://raw.githubusercontent.com/Kulwinderpal/My-Zsh/refs/heads/main/.zshrc -o "$T" \
  && mv "$T" ~/.zshrc || { err "Failed to download .zshrc"; rm -f "$T"; }

mkdir -p ~/.config/fastfetch
T=$(mktemp); curl -fsSL https://raw.githubusercontent.com/Kulwinderpal/My-Zsh/main/config.jsonc -o "$T" \
  && mv "$T" ~/.config/fastfetch/config.jsonc || { err "Failed to download fastfetch config.jsonc"; rm -f "$T"; }

echo "Done. To make zsh your default shell: chsh -s $(command -v zsh)"
if [ -f ~/.zshrc.bak ]; then
    echo "Your previous zshrc has been backed up at ~/.zshrc.bak"
fi