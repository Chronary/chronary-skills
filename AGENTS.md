# Agent Instructions for Chronary

This repository contains AI Agent Skills and IDE plugins for the [Chronary](https://chronary.ai) calendar API. The content here teaches AI coding assistants — including OpenAI Codex, Claude Code, Cursor, GitHub Copilot, and Windsurf — how to write correct Chronary integrations.

## What Chronary Is

Chronary is a calendar-as-a-service platform purpose-built for AI agents. It lets agents own calendars, create events, query availability, subscribe to external iCal feeds, and receive webhook notifications.

- API: `https://api.chronary.ai`
- OpenAPI spec: `https://api.chronary.ai/openapi.json`
- Docs: `https://docs.chronary.ai`
- Auth: Bearer API keys with prefix `chr_sk_` (org-level) or `chr_ak_` (agent-scoped). Legacy `chr_sk_live_*` / `chr_ak_live_*` keys still authenticate.

## Skill Files

When asked about Chronary, load the appropriate skill from this repository:

| Skill | When to use |
| --- | --- |
| [`skills/chronary-api/SKILL.md`](skills/chronary-api/SKILL.md) | REST API: data model, endpoints, ID prefixes, error codes, authentication |
| [`skills/chronary-toolkit/SKILL.md`](skills/chronary-toolkit/SKILL.md) | `@chronary/toolkit` — 23 tools for Vercel AI SDK, OpenAI, LangChain, Mastra, MCP |
| [`skills/chronary-mcp/SKILL.md`](skills/chronary-mcp/SKILL.md) | `@chronary/mcp` — MCP server setup for Claude Desktop, Cursor, VS Code, Windsurf |
| [`skills/chronary-cli/SKILL.md`](skills/chronary-cli/SKILL.md) | `chronary` CLI — command reference, scripting patterns |

## Reference Documents

| Reference | Contents |
| --- | --- |
| [`references/api-reference.md`](references/api-reference.md) | TypeScript SDK method signatures |
| [`references/examples.md`](references/examples.md) | End-to-end code examples |
| [`references/webhook-events.md`](references/webhook-events.md) | All 12 webhook event types with payload schemas |

## Conventions to Follow

- **ID prefixes:** `agt_` (agent), `cal_` (calendar), `evt_` (event), `whk_` (webhook), `sub_` (iCal subscription), `feed_` (iCal feed), `prp_` (proposal), `res_` (response).
- **API keys:** Use `chr_sk_*` for org-level operations and `chr_ak_*` when acting on behalf of a specific agent.
- **Webhook events** follow `entity.action` (singular noun): for example `event.created`, `calendar.deleted`, `proposal.confirmed`.
- **MCP server:** Distributed as `@chronary/mcp` on npm. Run with `npx -y @chronary/mcp` and set `CHRONARY_API_KEY` via env or `--api-key`.
- **Read-only tools** (`list_*`, `get_*`, `check_availability`) can be auto-approved by MCP clients. Write/delete tools should require confirmation.

## Do Not

- Do not invent endpoints or event types not listed in the skill files.
- Do not hardcode API keys in code — read from `CHRONARY_API_KEY` env var.
- Do not assume calendar tokens are public; iCal feed tokens are user secrets.
