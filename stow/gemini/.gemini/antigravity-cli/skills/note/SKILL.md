---
name: note
description: Save a standalone Markdown note to ~/Documents/notes/[subdir]/ with timestamp prepended.
---

# Note Saving Skill

Compose and save a structured Markdown note to local user documentation.

## Usage
* `/note <content>`: Compose and save note with user-provided content.

## Note Requirements
1. **Target Directory**: Save under `~/Documents/notes/[subdir]/` (default: `~/Documents/notes/misc/`).
2. **Filename Format**: `YYYYMMDDHHMM_keywords.md` (e.g., `202608061937_neovim_autoread_fix.md`).
3. **Content Structure**: First line must be a Markdown H1 (`# Heading`), followed by structured clean Markdown.
