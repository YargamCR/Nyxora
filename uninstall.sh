
#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
NYXORA_HOME="$DATA_HOME/nyxora"
STATE_ROOT="$NYXORA_HOME/installation"
ORIGINALS="$STATE_ROOT/originals"
MANIFEST="$STATE_ROOT/manifest"
MARKER="$STATE_ROOT/initialized"
HISTORY="$NYXORA_HOME/installation-history"
BIN="$HOME/.local/bin"
STAMP="$(date +%Y%m%d-%H%M%S)"

# Require a valid installation record before removing anything.
if [[ ! -f "$MARKER" || ! -f "$MANIFEST" || ! -d "$ORIGINALS" ]]; then
  echo "No valid Nyxora installation record was found." >&2
  echo "Nothing was removed." >&2
  exit 1
fi

# Validate every manifest entry and its required backup.
for name in awesome rofi alacritty picom; do
  action="$(awk -F= -v key="$name" '$1 == key { print $2; exit }' "$MANIFEST")"

  case "$action" in
    restore)
      if [[ ! -e "$ORIGINALS/$name" && ! -L "$ORIGINALS/$name" ]]; then
        echo "Original backup missing for $name. Aborting." >&2
        exit 1
      fi
      ;;
    skip|absent) ;;
    *)
      echo "Invalid or missing manifest entry for $name. Aborting." >&2
      exit 1
      ;;
  esac
done

SAFETY_ROOT="$NYXORA_HOME/uninstall-snapshots"
SAFETY="$SAFETY_ROOT/$STAMP"

echo "Nyxora uninstaller"
echo "Current configurations will be saved to: $SAFETY"
echo
cat "$MANIFEST"
echo

read -r -p "Continue? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

mkdir -p "$CONFIG_HOME" "$SAFETY_ROOT"
mkdir "$SAFETY"

for name in awesome rofi alacritty picom; do
  target="$CONFIG_HOME/$name"
  previous="$ORIGINALS/$name"
  action="$(awk -F= -v key="$name" '$1 == key { print $2; exit }' "$MANIFEST")"

  # Preserve the current configuration before removing it.
  if [[ -e "$target" || -L "$target" ]]; then
    cp -a -- "$target" "$SAFETY/"
    rm -rf -- "$target"
    echo "Removed Nyxora configuration: $name"
  fi

  case "$action" in
    restore)
      cp -a -- "$previous" "$CONFIG_HOME/"
      echo "Restored original configuration: $name"
      ;;
    skip)
      echo "Skipped restoration: $name"
      ;;
    absent)
      echo "No previous configuration existed: $name"
      ;;
  esac
done

rm -f -- "$BIN/nyxora-theme" "$BIN/nyxora-check"

# Archive the installation record instead of deleting it.
mkdir -p "$HISTORY"
mv -- "$STATE_ROOT" "$HISTORY/$STAMP"

echo
echo "Nyxora configuration uninstalled."
echo "Current configuration snapshot: $SAFETY"
echo "Installation record archived: $HISTORY/$STAMP"
echo "Previous backups were preserved."
