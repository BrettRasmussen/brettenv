#!/bin/bash
echo "Generating Brewfile from currently installed packages..."
brew bundle dump --force
echo "Brewfile updated."
