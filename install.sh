
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
NYXORA_HOME="$DATA_HOME/nyxora"
STATE_ROOT="$NYXORA_HOME/installation"
ORIGINALS="$STATE_ROOT/originals"
MANIFEST="$STATE_ROOT/manifest"
MARKER="$STATE_ROOT/initialized"
BIN="$HOME/.local/bin"
INSTALL_DEPS=0

usage() {
  cat <<'USAGE'
Nyxora installer

Usage: ./install.sh [--install-deps] [--help]

  (no option)     Install configuration without installing packages.
  --install-deps  Install dependencies using the detected package manager.
  --help          Show this help.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --install-deps) INSTALL_DEPS=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

for name in awesome rofi alacritty picom; do
  [[ -d "$ROOT/.config/$name" ]] || {
    echo "Missing project configuration: .config/$name" >&2
    exit 1
  }
done

install_dependencies() {
  if command -v pacman >/dev/null 2>&1; then
    echo "Detected pacman (Arch Linux / CachyOS)."
    sudo pacman -S --needed \
      awesome rofi alacritty picom ttf-jetbrains-mono-nerd \
      xorg-server xorg-xinit feh network-manager-applet
  elif command -v dnf5 >/dev/null 2>&1; then
    echo "Detected dnf5."
    sudo dnf5 install -y \
      awesome rofi alacritty picom jetbrains-mono-fonts-all \
      xorg-x11-server-Xorg xorg-x11-xinit feh NetworkManager-applet
  elif command -v dnf >/dev/null 2>&1; then
    echo "Detected dnf."
    sudo dnf install -y \
      awesome rofi alacritty picom jetbrains-mono-fonts-all \
      xorg-x11-server-Xorg xorg-x11-xinit feh NetworkManager-applet
  else
    echo "Unsupported package manager. Supported: pacman, dnf5, dnf." >&2
    exit 1
  fi
}

if [[ "$INSTALL_DEPS" -eq 1 ]]; then
  install_dependencies
fi

missing=()
for cmd in awesome rofi alacritty picom; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

if ((${#missing[@]})); then
  printf 'Missing required applications: %s\n' "${missing[*]}" >&2
  echo "Install them manually or rerun with --install-deps." >&2
  exit 1
fi

mkdir -p "$CONFIG_HOME" "$BIN" "$NYXORA_HOME"

# Capture original configurations only on the first installation.
if [[ ! -f "$MARKER" ]]; then
  if [[ -e "$ORIGINALS" || -e "$MANIFEST" ]]; then
    echo "Incomplete Nyxora installation state found at $STATE_ROOT." >&2
    echo "Inspect it before continuing; no configuration was changed." >&2
    exit 1
  fi

  mkdir -p "$STATE_ROOT"
  STAGING="$(mktemp -d "$STATE_ROOT/.originals.XXXXXX")"
  MANIFEST_TMP="$STATE_ROOT/.manifest.tmp"

  : > "$MANIFEST_TMP"

  for name in awesome rofi alacritty picom; do
    target="$CONFIG_HOME/$name"

    if [[ -e "$target" || -L "$target" ]]; then
      cp -a -- "$target" "$STAGING/$name"
      printf '%s=restore\n' "$name" >> "$MANIFEST_TMP"
      echo "Saved original configuration: $name"
    else
      printf '%s=absent\n' "$name" >> "$MANIFEST_TMP"
      echo "No previous configuration: $name"
    fi
  done

  mv -- "$STAGING" "$ORIGINALS"
  mv -- "$MANIFEST_TMP" "$MANIFEST"
  touch "$MARKER"
  echo "Original configuration state initialized."
else
  [[ -f "$MANIFEST" && -d "$ORIGINALS" ]] || {
    echo "Nyxora installation state is incomplete. Aborting." >&2
    exit 1
  }
  echo "Existing original backups preserved."
fi

# Validate the saved state before replacing anything.
for name in awesome rofi alacritty picom; do
  action="$(awk -F= -v key="$name" '$1 == key { print $2; exit }' "$MANIFEST")"

  case "$action" in
    restore|skip|absent) ;;
    *)
      echo "Invalid or missing manifest entry for $name. Aborting." >&2
      exit 1
      ;;
  esac

  if [[ "$action" == "restore" ]] &&
     [[ ! -e "$ORIGINALS/$name" && ! -L "$ORIGINALS/$name" ]]; then
    echo "Original backup missing for $name. Aborting." >&2
    exit 1
  fi
done

# Replace the configurations with Nyxora files.
for name in awesome rofi alacritty picom; do
  target="$CONFIG_HOME/$name"
  rm -rf -- "$target"
  mkdir -p "$target"
  cp -a "$ROOT/.config/$name/." "$target/"
  echo "Installed configuration: $name"
done

install -Dm755 "$ROOT/scripts/theme-switch" "$BIN/nyxora-theme"
install -Dm755 "$ROOT/scripts/nyxora-check" "$BIN/nyxora-check"

ln -sfnT "themes/dark.lua" "$CONFIG_HOME/awesome/theme.lua"
ln -sfnT "themes/dark.rasi" "$CONFIG_HOME/rofi/theme.rasi"

if [[ -d "$ROOT/wallpapers" ]]; then
  mkdir -p "$NYXORA_HOME/wallpapers"
  cp -an "$ROOT/wallpapers/." "$NYXORA_HOME/wallpapers/"
fi

printf '\nNyxora installed successfully.\n'
printf 'Original configurations: %s\n' "$ORIGINALS"
printf 'Commands: nyxora-check | nyxora-theme dark | nyxora-theme light\n'
printf 'If ~/.local/bin is not in Fish PATH: fish_add_path ~/.local/bin\n'
printf 'Validate with: awesome -k\n'
printf 'Note: Nyxora requires an X11 session.\n'
