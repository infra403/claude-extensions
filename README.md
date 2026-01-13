# Claude Extensions

Collection of Claude Code plugins and extensions.

## Extensions

### [bmad-auto](./bmad-auto/)

Automated story completion for BMad Method using official Ralph Loop.

- **Clean Context Per Story**: Uses Subagent for each story, avoiding context bloat
- **Zero Manual Intervention**: Once started, runs automatically until completion
- **Uses Official Ralph Loop**: Built on Claude Code's official Ralph Loop plugin

#### Installation

```bash
# Copy the bmad-auto command to your project
mkdir -p .claude/commands
cp claude-extensions/bmad-auto/commands/bmad-auto.md .claude/commands/
```

See [bmad-auto/README.md](./bmad-auto/README.md) for details.
