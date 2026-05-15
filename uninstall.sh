#!/bin/bash

STOW_DIR="$(pwd)/stow"
PACKAGES=$(ls -1 "$STOW_DIR" | xargs)

echo "=== Brettenv Uninstaller ==="

echo "Removing stowed symlinks for: $PACKAGES"
stow -D -v -d "$STOW_DIR" -t ~ $PACKAGES

echo "Cleaning up unmodified local configuration templates..."
for template in examples/*.example; do
    target="$HOME/.$(basename "$template" .example)"
    if [[ -f "$target" ]] && cmp -s "$template" "$target"; then
        echo "Removing unmodified $target"
        rm "$target"
    fi
done

echo "Note: Backups of original files are located in .devinfo/backups/"
echo "You will need to manually restore them."
echo "Also, Homebrew packages installed via Brewfile have not been uninstalled."

echo "=== Uninstall Complete ==="
