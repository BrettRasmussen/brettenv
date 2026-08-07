---
name: backups
description: Audit modified working files and run file backups under .devinfo/backups/.
---

# File Backup Skill

Audit task working files and store updated backups under `.devinfo/backups/`.

## Usage
* `/backups`: Run a manual backup pass on all modified files in the current task.

## Backup Protocol
1. Retrieve working file list for the active task.
2. Compare each file's last-modified timestamp with its latest backup in `.devinfo/backups/`.
3. Save updated backups using `.devinfo/backups/PATH/BASENAME.YYYYMMDDHHMM.EXT`.
