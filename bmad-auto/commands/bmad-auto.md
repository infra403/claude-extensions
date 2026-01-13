---
description: Auto complete all BMad stories using official Ralph Loop
allowed-tools: ["Task", "Bash"]
---

# BMad Auto - Using Official Ralph Loop

Complete all `ready-for-dev` stories in the sprint.

```!
# Find sprint status file
STATUS_FILE="sprint-status.yaml"
test -f "$STATUS_FILE" || STATUS_FILE="_bmad-output/implementation-artifacts/sprint-status.yaml"

test -f "$STATUS_FILE" || { echo "❌ sprint-status.yaml not found!"; exit 1; }

# Count stories
TOTAL_STORIES=$(grep -c '^  [0-9].*: ready-for-dev$' "$STATUS_FILE")

echo "🚀 BMad Auto: $TOTAL_STORIES stories to complete"

# Find ralph-loop plugin root
RALPH_PLUGIN_ROOT=".claude/plugins/ralph-loop"

# Start Ralph Loop
"${RALPH_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" "Complete all BMad stories with status 'ready-for-dev'. Use Subagent for each story with clean context. Update sprint-status.yaml after each completion. When no more 'ready-for-dev' stories remain, output <promise>ALL_STORIES_COMPLETE</promise>" --completion-promise "ALL_STORIES_COMPLETE"
```

## Instructions (Same for every iteration)

You are in **Ralph Loop Mode**. Your goal is to complete ALL stories with status `ready-for-dev` in `{{STATUS_FILE}}`.

### Each Iteration:

1. **Check current status** - Read `{{STATUS_FILE}}` and find which stories are:
   - `done` (already completed)
   - `ready-for-dev` (need to complete)
   - `in-progress` (currently working)

2. **Find the next story** - Pick the first `ready-for-dev` or `in-progress` story

3. **Complete the story** - Launch a Subagent:
   ```
   Task tool:
   - subagent_type: "general-purpose"
   - prompt: "Execute /bmad:bmm:workflows:dev-story <STORY_KEY>. Follow all workflow instructions, implement all tasks, run tests, commit changes."
   ```

4. **Update status** - After Subagent completes:
   - Mark the story as `done` in `{{STATUS_FILE}}`
   - Commit the status update

5. **Check if done** - If no more `ready-for-dev` stories:
   - Output: `<promise>ALL_STORIES_COMPLETE</promise>`
   - Stop the loop

6. **Continue** - If more stories remain, this iteration ends. Ralph Loop will inject this SAME prompt back, and you repeat the process for the next story.

**Ralph Loop is now active. Start with the first ready-for-dev story.**
