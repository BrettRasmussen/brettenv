---
name: format
description: Audit and fix code formatting (2-space indents, paired constructs, 120-char line width) on a file.
---

# Code Formatting Skill

Audit and fix code formatting on a target file to align with project standards.

## Usage
* `/format <filepath>`

## Audit Protocol
1. Verify 2-space indentation (no raw tabs).
2. Ensure block constructs (`if...else...end`, `<p>...</p>`, brackets) are properly closed and aligned.
3. Remove trailing whitespace and empty lines containing only whitespace.
4. Wrap lines wider than 120 characters onto multiple lines wherever possible.
5. Re-run relevant unit/integration tests if any formatting change could alter code execution behavior.
