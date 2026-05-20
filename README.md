# Chronary Skills

Agent skills and IDE plugins for the [Chronary](https://chronary.ai) calendar API. These teach AI coding assistants how to write correct Chronary integrations.

## What are Agent Skills?

Agent Skills are structured documentation files that AI coding assistants (Claude Code, Cursor, VS Code Copilot, OpenAI Codex, Windsurf) load to understand your API. They contain no executable code — just reference material in markdown format following the [Agent Skills specification](https://agentskills.io/specification).

## Skills Included

| Skill | Description |
|-------|-------------|
| [`chronary-api`](skills/chronary-api/SKILL.md) | Core REST API — data model, endpoints, authentication, error handling |
| [`chronary-toolkit`](skills/chronary-toolkit/SKILL.md) | Framework toolkit — 23 tools with adapters for Vercel AI SDK, OpenAI, LangChain, Mastra, MCP |
| [`chronary-mcp`](skills/chronary-mcp/SKILL.md) | MCP server (`@chronary/mcp`) configuration for Claude Desktop, Cursor, VS Code, Windsurf |
| [`chronary-cli`](skills/chronary-cli/SKILL.md) | CLI tool — command reference, scripting, automation patterns |

## Reference Documents

| Document | Description |
|----------|-------------|
| [`api-reference.md`](references/api-reference.md) | Complete TypeScript SDK method signatures |
| [`examples.md`](references/examples.md) | Code examples covering all resource types |
| [`webhook-events.md`](references/webhook-events.md) | All 12 webhook event types with payload schemas |

## Installation

### One-liner installer

macOS / Linux / WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/Chronary/chronary-skills/main/install.sh | bash
```

Windows PowerShell:

```powershell
iwr -useb https://raw.githubusercontent.com/Chronary/chronary-skills/main/install.ps1 | iex
```

Targets: `claude-code` · `cursor` · `windsurf` · `vscode` · `codex` · `all` (default).

```bash
# Install for one target only:
curl -fsSL https://raw.githubusercontent.com/Chronary/chronary-skills/main/install.sh | bash -s -- claude-code
```

### Claude Code (plugin marketplace)

This repo ships a Claude Code plugin marketplace. Inside Claude Code:

```text
/plugin marketplace add Chronary/chronary-skills
/plugin install chronary@chronary
```

That installs the `chronary` plugin (all four skills, three slash commands, and the MCP server config in one bundle).

### Cursor

```bash
# User-level (preferred for shared knowledge)
cp -r skills/* ~/.cursor/skills/

# Or project-level
cp -r skills/ .cursor/skills/
```

### VS Code Copilot

VS Code Copilot's "Agent Skills" load from `.github/skills/` in the repo. This repo ships pre-staged copies at `.github/skills/`, so:

```bash
cp -r .github/skills/* /path/to/your/project/.github/skills/
```

### OpenAI Codex

Codex reads `AGENTS.md` at the repo root and `~/.codex/skills/`:

```bash
cp -r skills/* ~/.codex/skills/
cp AGENTS.md ~/.codex/AGENTS.md
```

### Windsurf

```bash
cp -r skills/* ~/.windsurf/skills/
```

## MCP Server

The Chronary MCP server is published to npm as [`@chronary/mcp`](https://www.npmjs.com/package/@chronary/mcp). Run it from any MCP-capable client:

```bash
export CHRONARY_API_KEY=chr_sk_...
npx -y @chronary/mcp
```

Full per-editor configuration is in [`skills/chronary-mcp/SKILL.md`](skills/chronary-mcp/SKILL.md).

## Links

- [Chronary API Docs](https://docs.chronary.ai)
- [OpenAPI Spec](https://api.chronary.ai/openapi.json)
- [TypeScript SDK](https://github.com/Chronary/chronary-node) (`@chronary/sdk`)
- [Python SDK](https://github.com/Chronary/chronary-python) (`chronary`)
- [CLI Tool](https://github.com/Chronary/chronary-cli) (`chronary`)
- [MCP Server](https://github.com/Chronary/chronary-mcp) (`@chronary/mcp`)
- [Toolkit](https://github.com/Chronary/chronary-toolkit) (`@chronary/toolkit`)
- [Schemas](https://github.com/Chronary/chronary-schemas) (`@chronary/schemas`)

## License

MIT
