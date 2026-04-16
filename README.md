# Chronary Skills

Agent skills and IDE plugins for the [Chronary](https://chronary.ai) calendar API. These teach AI coding assistants how to write correct Chronary integrations.

## What are Agent Skills?

Agent Skills are structured documentation files that AI coding assistants (Claude Code, Cursor, VS Code Copilot, OpenAI Codex, Windsurf) load to understand your API. They contain no executable code -- just reference material in markdown format following the [Agent Skills specification](https://agentskills.io/specification).

## Skills Included

| Skill | Description |
|-------|-------------|
| [`chronary-api`](skills/chronary-api/SKILL.md) | Core REST API -- data model, endpoints, authentication, error handling |
| [`chronary-toolkit`](skills/chronary-toolkit/SKILL.md) | Framework toolkit -- 23 tools with adapters for Vercel AI SDK, OpenAI, LangChain, Mastra, MCP |
| [`chronary-mcp`](skills/chronary-mcp/SKILL.md) | MCP server configuration for Claude Desktop, Cursor, VS Code, Windsurf |
| [`chronary-cli`](skills/chronary-cli/SKILL.md) | CLI tool -- command reference, scripting, automation patterns |

## Reference Documents

| Document | Description |
|----------|-------------|
| [`api-reference.md`](references/api-reference.md) | Complete TypeScript SDK method signatures |
| [`examples.md`](references/examples.md) | Code examples covering all resource types |
| [`webhook-events.md`](references/webhook-events.md) | All 12 webhook event types with payload schemas |

## Installation

### Claude Code

Copy the skills directory into your project:

```bash
# Project-level (recommended)
cp -r skills/ .claude/skills/

# Or install the plugin
# (plugin marketplace support coming soon)
```

### Cursor

```bash
# User-level
cp -r skills/* ~/.cursor/skills/

# Or project-level
cp -r skills/ .cursor/skills/
```

### VS Code Copilot

```bash
cp -r skills/* .github/skills/
```

### OpenAI Codex

```bash
cp -r skills/ skills/
```

### Windsurf

```bash
cp -r skills/* ~/.windsurf/skills/
```

## Links

- [Chronary API Docs](https://docs.chronary.ai)
- [OpenAPI Spec](https://api.chronary.ai/openapi.json)
- [TypeScript SDK](https://github.com/Chronary/chronary-node) (`@chronary/sdk`)
- [Python SDK](https://github.com/Chronary/chronary-python) (`chronary`)
- [CLI Tool](https://github.com/Chronary/chronary-cli) (`chronary`)
- [MCP Server](https://github.com/Chronary/chronary-mcp) (`chronary-mcp`)

## License

MIT
