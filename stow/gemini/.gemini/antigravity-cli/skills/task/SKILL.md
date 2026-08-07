---
name: task
description: Switch active task context, create .devinfo/tasks/${TASKNAME}/, and load task files.
---

# Task Management Skill

Switch the active task for the current session or terminal pane.

## Usage
* `/task <taskname>`: Switch to the specified task context.
* `/task:read`: Read all collaborative task files under `.devinfo/tasks/${TASKNAME}/`.
* `/task:save`: Save current task state and context notes.

## Execution Sequence
1. Identify `SESSION_KEY=${TMUX_PANE:-$(tty | awk -F/ '{print $NF}')}`.
2. Store `<taskname>` into `.devinfo/active_sessions/${SESSION_KEY}`.
3. Set `${TASK_SUBDIR}` to `.devinfo/tasks/${TASKNAME}/`.
4. If `${TASKNAME}` is `"new"`, operate in memory without reading or creating task files.
5. If `${TASK_SUBDIR}` exists, read `task.md`, `plan.md`, `todo.md`, `changes.md`, and `ai_notes.md`.
6. If `${TASK_SUBDIR}` does not exist, create the directory and initialize standard collaborative files.
7. Automatically adopt Information Provider mode (`[INFO MODE]`) upon completing task setup.
