# BMad Method Auto Plugin

Fully automated story completion for BMad Method - zero manual intervention required.

## Overview

This plugin automates the process of completing BMad Method stories by:
1. Finding the next story from `sprint-status.yaml`
2. Starting a **fresh Claude Code session** for each story (clean context!)
3. Completing the story
4. Updating status and automatically continuing to the next story
5. Repeating until all stories are done

## Key Feature: Clean Context Per Story

```
┌─────────────────────────────────────────────────────────────────────┐
│                    User runs: /bmad-auto-sprint                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  External Bash Loop                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                                                              │   │
│  │  Story 1: New Claude Code process → Clean context           │   │
│  │    ├── Switch to dev branch                                 │   │
│  │    ├── Implement story                                       │   │
│  │    ├── Run tests                                             │   │
│  │    ├── Commit changes                                        │   │
│  │    └── Exit (Stop Hook updates status)                       │   │
│  │                                                              │   │
│  │  Story 2: New Claude Code process → Clean context again!    │   │
│  │    └── (repeat...)                                           │   │
│  │                                                              │   │
│  │  Story 3: New Claude Code process → Clean context again!    │   │
│  │    └── (repeat...)                                           │   │
│  │                                                              │   │
│  │  ...until all stories complete                               │   │
│  │                                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Auto-complete ALL stories
/bmad-auto-sprint

# Limit to specific number
/bmad-auto-sprint --max-stories 5
```

That's it! The plugin handles everything else automatically.

## Workflow

```
User: /bmad-auto-sprint
        ↓
┌──────────────────────────────────────────────────────┐
│ 1. Find next backlog story from sprint-status.yaml   │
│ 2. Create bash loop script                           │
│ 3. Start loop:                                       │
│                                                      │
│    FOR EACH STORY:                                   │
│    ├─ Mark story as "in-progress"                    │
│    ├─ Start NEW Claude Code process                  │
│    ├─ Claude works with FRESH context                │
│    ├─ Claude outputs <STORY_COMPLETE>                │
│    ├─ Stop Hook updates sprint-status.yaml           │
│    ├─ Commit changes                                 │
│    └─ Loop continues to next story                   │
│                                                      │
│ 4. When no more stories: Show completion message     │
└──────────────────────────────────────────────────────┘
```

## Commands

| Command | Description |
|---------|-------------|
| `/bmad-auto-sprint` | Start automated sprint (all stories) |
| `/bmad-auto-sprint --max-stories N` | Limit to N stories |
| `/cancel-bmad-loop` | Cancel active sprint |

## Why This Approach?

| Problem | Solution |
|---------|----------|
| Ralph Wiggum causes context explosion | Each story = new process = clean context |
| Manual restart is tedious | Bash script handles automatic restarts |
| Can't automate fully | One command runs everything |

## Completion Signal

Stories are marked complete when Claude outputs:
```
<promise><STORY_COMPLETE></promise>
```

The Stop Hook detects this and:
1. Marks current story as `done`
2. Marks next story as `in-progress`
3. Commits the changes
4. Exits cleanly

The bash loop then automatically starts the next story.

## State Files

| File | Purpose |
|------|---------|
| `sprint-status.yaml` | BMad Method's sprint state (updated after each story) |
| `.claude/bmad-auto-loop.sh` | Temporary loop script (auto-created, cleaned up) |
| `.claude/current-story.md` | Current story task file (per session) |

## Example Output

```
🚀 BMad Auto Sprint Started!
Max stories: 0 (unlimited)

═══════════════════════════════════════════════════════════
Starting story: 1-1-user-registration
Stories completed: 0
═══════════════════════════════════════════════════════════

[Claude works on story...]

═══════════════════════════════════════════════════════════
✅ STORY COMPLETE: 1-1-user-registration
→ Next story: 1-2-user-authentication (auto-continuing)
═══════════════════════════════════════════════════════════

Continuing to next story...

═══════════════════════════════════════════════════════════
Starting story: 1-2-user-authentication
Stories completed: 1
═══════════════════════════════════════════════════════════

[...and so on until all stories complete...]
```

## Requirements

- BMad Method project with `sprint-status.yaml`
- `git` version control
- Dev branch exists
- `jq` for JSON parsing (Stop Hook)

## Files Structure

```
bmad-auto/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── bmad-auto-sprint.md       # Main automated sprint command
│   └── cancel-bmad-loop.md       # Cancel command
├── hooks/
│   ├── hooks.json
│   └── stop-hook.sh              # Detect completion, update status
└── README.md
```
