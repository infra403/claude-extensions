# BMad Auto Plugin

Automated story completion for BMad Method using official Ralph Loop.

## Overview

`bmad-auto` automates completing BMad Method stories by:
- Finding all `ready-for-dev` stories from `sprint-status.yaml`
- Processing each story with **clean context** using Subagent
- Automatically continuing to the next story
- Repeating until all stories are done

## Key Features

- **Clean Context Per Story**: Uses Subagent for each story, avoiding context bloat
- **Zero Manual Intervention**: Once started, runs automatically until completion
- **Uses Official Ralph Loop**: Built on Claude Code's official Ralph Loop plugin

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    User runs: /bmad-auto                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Bash: Find stories, start Ralph Loop                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│           Ralph Loop - Automatic Iteration                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Each Iteration:                                       │    │
│  │ 1. Read sprint-status.yaml                           │    │
│  │ 2. Find next ready-for-dev story                     │    │
│  │ 3. Launch Subagent (clean context)                   │    │
│  │ 4. Update status to done                             │    │
│  │ 5. If no more stories → output <promise> → exit      │    │
│  │ 6. Otherwise → Stop Hook repeats same prompt         │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Installation

### Option 1: Install from GitHub (Recommended)

```bash
# Clone or download this repository
cd /path/to/your/project

# Copy the bmad-auto command to your project
mkdir -p .claude/commands
cp claude-extensions/bmad-auto/commands/bmad-auto.md .claude/commands/
```

### Option 2: Manual Install

1. Create `.claude/commands/bmad-auto.md` in your project
2. Copy the content from [commands/bmad-auto.md](commands/bmad-auto.md)

## Requirements

| Requirement | Description |
|-------------|-------------|
| **Ralph Loop Plugin** | Must be installed: `claude-code plugin install ralph-loop` |
| **BMad Method** | Project with `sprint-status.yaml` |
| **Dev Story Command** | `/bmad:bmm:workflows:dev-story` must be available |

### Install Ralph Loop

```bash
claude-code plugin install ralph-loop
```

Or manually from: https://github.com/anthropics/ralph-loop

## Usage

```bash
# Start automated story completion
/bmad-auto
```

That's it! The plugin will:
1. Count `ready-for-dev` stories
2. Start Ralph Loop
3. Process each story automatically
4. Exit when all stories are complete

## Example Output

```
🔄 Ralph loop activated in this session!

Iteration: 1
Max iterations: unlimited
Completion promise: ALL_STORIES_COMPLETE (ONLY output when TRUE)

...
🚀 BMad Auto: 3 stories to complete

[Processing story 1...]
✅ Story complete, updating status...

[Processing story 2...]
✅ Story complete, updating status...

[Processing story 3...]
✅ All stories complete!

<promise>ALL_STORIES_COMPLETE</promise>

✅ Ralph loop: Detected ALL_STORIES_COMPLETE
```

## How Stories Are Processed

Each story is processed by a **Subagent** with clean context:

```
Main Session (Ralph Loop)
├── Tracks overall progress
├── Reads sprint-status.yaml
└── Subagent per story
    ├── Clean context (no bloat)
    ├── Executes /bmad:bmm:workflows:dev-story
    ├── Implements, tests, commits
    └── Returns result
```

## Completion Signal

The loop stops when Claude outputs:
```
<promise>ALL_STORIES_COMPLETE</promise>
```

This is only output when **all** `ready-for-dev` stories are done.

## Files

| File | Purpose |
|------|---------|
| `.claude/commands/bmad-auto.md` | Main command file |
| `.claude/plugins/ralph-loop/` | Official Ralph Loop plugin (required) |
| `sprint-status.yaml` | BMad Method sprint state |

## Troubleshooting

### Ralph Loop not found
```bash
# Install official Ralph Loop plugin
claude-code plugin install ralph-loop
```

### sprint-status.yaml not found
Ensure you're in a BMad Method project with the sprint file at:
- `sprint-status.yaml` (root)
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Loop not continuing
Check Ralph Loop state:
```bash
head -10 .claude/ralph-loop.local.md
```

To cancel, delete the state file:
```bash
rm .claude/ralph-loop.local.md
```

## License

MIT
