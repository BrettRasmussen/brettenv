#!/bin/bash

# Configuration
STOW_DIR="$(pwd)/stow"
BACKUP_DIR="$(pwd)/.devinfo/backups/host_files_$(date +%Y%m%d%H%M)"
PACKAGES=$(ls -1 "$STOW_DIR" | xargs)

echo "=== Brettenv Installer ==="

# 1. Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
echo "Installing Brewfile dependencies..."
brew bundle

# Check if stow was installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is required but not found. Please install it manually."
    exit 1
fi

# 2. Local Config Templates
echo "Setting up local configuration templates..."
for template in examples/*.example; do
    target="$HOME/.$(basename "$template" .example)"
    if [[ ! -f "$target" ]]; then
        cp "$template" "$target"
        msg="Created $target"
        [[ "$target" == *".gitconfig.local" ]] && msg="$msg (Please edit this with your name/email)"
        echo "$msg"
    fi
done

# 3. Backup existing host files
echo "Checking for conflicts in your home directory..."
mkdir -p "$BACKUP_DIR"
for pkg in $PACKAGES; do
    # Using stow's conflict checking to find what needs backing up
    CONFLICTS=$(stow -n -v -d "$STOW_DIR" -t ~ $pkg 2>&1 | grep "existing target is not owned by stow:" | awk -F ': ' '{print $2}')
    for file in $CONFLICTS; do
        if [ -f ~/"$file" ] || [ -d ~/"$file" ]; then
            echo "Backing up existing ~/$file to $BACKUP_DIR/$file"
            mkdir -p "$BACKUP_DIR/$(dirname "$file")"
            mv ~/"$file" "$BACKUP_DIR/$file"
        fi
    done
done

# Clean up empty backup dir if no conflicts found
[ -z "$(ls -A "$BACKUP_DIR")" ] && rmdir "$BACKUP_DIR" && echo "No conflicts found."

# 4. Stow Packages
echo "Stowing packages: $PACKAGES"
stow -v -d "$STOW_DIR" -t ~ $PACKAGES

echo "=== Installation Complete ==="
echo "Note: If you have existing files that were backed up, you can find them in: $BACKUP_DIR"
