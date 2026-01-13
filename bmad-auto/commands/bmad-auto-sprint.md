---
description: Automatically complete all BMad Method stories
argument-hint: [--max-stories <n>]
allowed-tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob", "Skill", "TodoWrite"]
---

# BMad Auto Sprint

Automatically complete ALL BMad Method stories - no manual intervention needed.

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│                    User runs: /bmad-auto-sprint                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  External Bash Loop Script                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ while has_stories; do                                       │   │
│  │   1. Find next story from sprint-status.yaml                │   │
│  │   2. Start Claude Code (NEW process = clean context)        │   │
│  │   3. Claude completes ONE story                             │   │
│  │   4. Stop Hook updates status                               │   │
│  │   5. Exit this Claude Code session                          │   │
│  │   6. Bash loop auto-continues to next story                 │   │
│  │ done                                                          │   │
│  │                                                                │   │
│  │ echo "All stories completed!"                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Usage

```bash
# Auto-complete all stories
/bmad-auto-sprint

# Limit to specific number of stories
/bmad-auto-sprint --max-stories 5
```

## Step 1: Initialize Loop

```!
# Parse arguments
MAX_STORIES=0
if [[ "$ARGUMENTS" == *"--max-stories"* ]]; then
  MAX_STORIES=$(echo "$ARGUMENTS" | grep -o '--max-stories [0-9]*' | awk '{print $2}')
fi

# Find first story
STORY_KEY=$(grep -E ': (backlog|ready-for-dev)$' sprint-status.yaml 2>/dev/null | head -1 | sed 's/  \([^:]*\):.*/\1/')

if [[ -z "$STORY_KEY" ]]; then
  if grep -q ': in-progress$' sprint-status.yaml 2>/dev/null; then
    STORY_KEY=$(grep ': in-progress$' sprint-status.yaml | head -1 | sed 's/  \([^:]*\):.*/\1/')
  else
    echo "✅ All stories already completed!"
    cat sprint-status.yaml 2>/dev/null | grep -A 20 "development_status:" || true
    exit 0
  fi
fi

echo "TARGET_STORY=$STORY_KEY"
echo "MAX_STORIES=$MAX_STORIES"
```

## Step 2: Create Loop Script

```!
# Create the auto-loop script
cat > .claude/bmad-auto-loop.sh <<'LOOP_SCRIPT'
#!/bin/bash
set -euo pipefail

STORIES_COMPLETED=0
MAX_STORIES=${1:-0}  # 0 = unlimited

echo "🚀 BMad Auto Sprint Started!"
echo "Max stories: $MAX_STORIES (0 = unlimited)"
echo ""

while true; do
  # Check max stories limit
  if [[ "$MAX_STORIES" -gt 0 ]] && [[ "$STORIES_COMPLETED" -ge "$MAX_STORIES" ]]; then
    echo "✅ Reached max stories limit: $MAX_STORIES"
    break
  fi

  # Find next story
  STORY_KEY=$(grep -E ': (backlog|ready-for-dev|in-progress)$' sprint-status.yaml 2>/dev/null | head -1 | sed 's/  \([^:]*\):.*/\1/')

  if [[ -z "$STORY_KEY" ]]; then
    echo "✅ All stories completed!"
    echo ""
    echo "Final sprint status:"
    cat sprint-status.yaml | grep -A 20 "development_status:" || true
    break
  fi

  echo "═══════════════════════════════════════════════════════════"
  echo "Starting story: $STORY_KEY"
  echo "Stories completed: $STORIES_COMPLETED"
  echo "═══════════════════════════════════════════════════════════"
  echo ""

  # Mark as in-progress
  sed -i.bak "s/^  $STORY_KEY: .*/  $STORY_KEY: in-progress/" sprint-status.yaml
  rm -f sprint-status.yaml.bak

  # Create story task file for this session
  STORY_LOCATION=$(grep '^story_location:' sprint-status.yaml 2>/dev/null | sed 's/story_location: *//')
  [[ -z "$STORY_LOCATION" ]] && STORY_LOCATION="stories"

  cat > .claude/current-story.md <<EOF
---
story: $STORY_KEY
iteration: 1
---

# BMad Story: $STORY_KEY

$(cat "$STORY_LOCATION/$STORY_KEY.md" 2>/dev/null || echo "Story file not found")

## Instructions

1. Switch to dev branch: \`git checkout dev && git pull\`
2. Implement the story
3. Write and run tests
4. Commit changes

## When Complete

Update sprint-status.yaml:
- Mark this story as: \`done\`
- Find next story and mark as: \`in-progress\`
- Commit the status update

Then output: \`<promise><STORY_COMPLETE></promise>\`
EOF

  # Start Claude Code for this story
  # When Claude exits, check if story was completed
  export STORY_KEY
  export STORIES_COMPLETED

  # Use the claude command with the story task
  claude < .claude/current-story.md

  # Check if story was marked done
  if grep -q "^  $STORY_KEY: done" sprint-status.yaml; then
    STORIES_COMPLETED=$((STORIES_COMPLETED + 1))
    echo "✅ Story $STORY_KEY completed!"
  else
    echo "⚠️  Story $STORY_KEY was not completed. Stopping."
    break
  fi

  echo ""
  echo "Continuing to next story..."
  echo ""
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🎉 BMad Auto Sprint Finished!"
echo "Total stories completed: $STORIES_COMPLETED"
echo "═══════════════════════════════════════════════════════════"

# Clean up
rm -f .claude/current-story.md
LOOP_SCRIPT

chmod +x .claude/bmad-auto-loop.sh

echo "Loop script created: .claude/bmad-auto-loop.sh"
```

## Step 3: Execute Loop

```!
# Run the loop script
.claude/bmad-auto-loop.sh "$MAX_STORIES"
```

## Step 4: Clean Up (On Completion)

```!
# Remove loop script when done
rm -f .claude/bmad-auto-loop.sh .claude/current-story.md
echo "✅ Cleanup complete"
```

## Stop Hook Integration

The Stop Hook will:
1. Detect `<STORY_COMPLETE>` promise
2. Update sprint-status.yaml
3. Exit cleanly
4. Bash loop continues to next story

```!
# Show completion message
cat <<'EOF'

═══════════════════════════════════════════════════════════
✅ STORY COMPLETE: {{story_key}}
→ Bash loop will continue to next story automatically
═══════════════════════════════════════════════════════════

EOF
```

## Important Notes

- **Each story = New Claude Code process** = Clean context!
- **No manual intervention needed** - fully automated
- **Progress tracked** in sprint-status.yaml
- **Safe interrupt** - Ctrl+C will stop after current story

## Cancel

To cancel the sprint:
```bash
/cancel-bmad-loop
```
