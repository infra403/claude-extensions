---
description: Cancel active BMad Method automated loop
allowed-tools: ["Bash", "Read"]
---

# Cancel BMad Method Loop

Cancel the active BMad Method automated loop.

```!
if [[ -f ".claude/bmad-auto-loop.local.md" ]]; then
  ITERATION=$(grep '^iteration:' .claude/bmad-auto-loop.local.md | sed 's/iteration: *//')
  STORIES_COMPLETED=$(grep '^stories_completed:' .claude/bmad-auto-loop.local.md | sed 's/stories_completed: *//')
  CURRENT_STORY=$(grep '^current_story:' .claude/bmad-auto-loop.local.md | sed 's/current_story: *//')

  echo "✅ Cancelled BMad Method loop"
  echo ""
  echo "Progress:"
  echo "  Stories completed: $STORIES_COMPLETED"
  echo "  Current story: $CURRENT_STORY"
  echo "  Iterations: $ITERATION"

  rm .claude/bmad-auto-loop.local.md
else
  echo "No active BMad Method loop found."
fi
```
