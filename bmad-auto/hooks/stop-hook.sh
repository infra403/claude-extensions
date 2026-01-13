#!/bin/bash
# BMad Method Stop Hook
# Detects story completion and updates sprint status
# Works with external bash loop for clean context per story

set -euo pipefail

HOOK_INPUT=$(cat)
STATE_FILE=".claude/bmad-auto-loop.local.md"

# Check for completion promise in transcript
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path' // echo "")

if [[ -f "$TRANSCRIPT_PATH" ]]; then
  # Get last assistant output
  LAST_OUTPUT=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1 | jq -r '.message.content | map(select(.type == "text")) | map(.text) | join("\n")' 2>/dev/null || echo "")

  # Check for completion promise
  if echo "$LAST_OUTPUT" | grep -q "<STORY_COMPLETE>"; then
    # Extract story key from state file or env
    CURRENT_STORY="${STORY_KEY:-}"
    if [[ -z "$CURRENT_STORY" ]] && [[ -f "$STATE_FILE" ]]; then
      FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
      CURRENT_STORY=$(echo "$FRONTMATTER" | grep '^current_story:' | sed 's/current_story: *//' || echo "")
    fi

    if [[ -n "$CURRENT_STORY" ]]; then
      # Update sprint-status.yaml - mark current as done
      if [[ -f "sprint-status.yaml" ]]; then
        sed -i.bak "s/^  $CURRENT_STORY: .*/  $CURRENT_STORY: done/" sprint-status.yaml
        rm -f sprint-status.yaml.bak

        # Find and mark next story as in-progress
        NEXT_STORY=$(grep -E ': (backlog|ready-for-dev)$' sprint-status.yaml | head -1 | sed 's/  \([^:]*\):.*/\1/' || echo "")

        if [[ -n "$NEXT_STORY" ]]; then
          sed -i.bak "s/^  $NEXT_STORY: .*/  $NEXT_STORY: in-progress/" sprint-status.yaml
          rm -f sprint-status.yaml.bak

          # Commit the status update
          git add sprint-status.yaml 2>/dev/null || true
          git commit -m "chore: complete story $CURRENT_STORY, start $NEXT_STORY" 2>/dev/null || true
        else
          # All stories done
          git add sprint-status.yaml 2>/dev/null || true
          git commit -m "chore: complete story $CURRENT_STORY, sprint finished" 2>/dev/null || true
        fi
      fi

      echo ""
      echo "═══════════════════════════════════════════════════════════"
      echo "✅ STORY COMPLETE: $CURRENT_STORY"
      if [[ -n "$NEXT_STORY" ]]; then
        echo "→ Next story: $NEXT_STORY (auto-continuing)"
      else
        echo "→ All stories completed!"
      fi
      echo "═══════════════════════════════════════════════════════════"
      echo ""

      # Clean up state file
      rm -f "$STATE_FILE" 2>/dev/null || true
    fi

    # Exit cleanly - bash loop will continue to next story
    exit 0
  fi
fi

# No completion detected - continue normal flow
exit 0
