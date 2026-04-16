---
name: chronary-toolkit
description: Chronary Toolkit — 23 pre-built tools with framework adapters for Vercel AI SDK, OpenAI, LangChain, Mastra, and MCP.
---

# Chronary Toolkit

The `@chronary/toolkit` package provides 23 pre-built tools for AI agent frameworks. Each tool maps to Chronary API operations with typed parameters, descriptions, and MCP annotations.

```bash
npm install @chronary/toolkit
```

## Available Tools

### Calendars (5 tools)

| Tool | Description | Read-only | Destructive |
|------|-------------|-----------|-------------|
| `list_calendars` | List calendars, optionally filtered by agent. Returns paginated results. | Yes | No |
| `get_calendar` | Get a calendar by its ID, including its name, timezone, and iCal feed URL. | Yes | No |
| `create_calendar` | Create a new calendar. Specify a name and IANA timezone. Optionally scope it to an agent. | No | No |
| `update_calendar` | Update a calendar's name, timezone, or metadata. | No | No |
| `delete_calendar` | Permanently delete a calendar and all its events. | No | Yes |

### Events (5 tools)

| Tool | Description | Read-only | Destructive |
|------|-------------|-----------|-------------|
| `list_events` | List events on a calendar or for an agent. Supports date range and status filters. | Yes | No |
| `get_event` | Get a specific event by its calendar ID and event ID. | Yes | No |
| `create_event` | Create a new event on a calendar. Blocks the agent's availability during the time window. | No | No |
| `update_event` | Update an existing event's title, times, status, or other properties. | No | No |
| `delete_event` | Delete an event from a calendar. Frees the agent's availability during that time. | No | Yes |

### Availability (1 tool)

| Tool | Description | Read-only | Destructive |
|------|-------------|-----------|-------------|
| `check_availability` | Check free/busy availability across one or more agents within a time range. | Yes | No |

### Webhooks (5 tools)

| Tool | Description | Read-only | Destructive |
|------|-------------|-----------|-------------|
| `list_webhooks` | List all webhook subscriptions for the organization. | Yes | No |
| `get_webhook` | Get a webhook subscription by its ID. | Yes | No |
| `create_webhook` | Create a webhook subscription. Payloads signed with HMAC-SHA256. | No | No |
| `update_webhook` | Update a webhook's URL, subscribed events, or active status. | No | No |
| `delete_webhook` | Delete a webhook subscription. No further events delivered to this URL. | No | Yes |

### iCal Subscriptions (6 tools)

| Tool | Description | Read-only | Destructive |
|------|-------------|-----------|-------------|
| `list_ical_subscriptions` | List external calendar imports for an agent. | Yes | No |
| `get_ical_subscription` | Get an iCal subscription by its ID, including sync status and last error. | Yes | No |
| `create_ical_subscription` | Import an external calendar by subscribing to an iCal feed URL. Synced every 15 min. | No | No |
| `update_ical_subscription` | Update an iCal subscription's label or feed URL. | No | No |
| `delete_ical_subscription` | Remove an external calendar import. Previously synced events remain. | No | Yes |
| `sync_ical_subscription` | Trigger an immediate sync instead of waiting for the 15-minute poll. | No | No |

### Usage (1 tool)

| Tool | Description | Read-only | Destructive |
|------|-------------|-----------|-------------|
| `get_usage` | Get quota and usage statistics for the current billing period. | Yes | No |

## Framework Adapters

### Vercel AI SDK

```typescript
import { ChronaryToolkit } from '@chronary/toolkit/ai-sdk';

const toolkit = new ChronaryToolkit({ apiKey: process.env.CHRONARY_API_KEY });
const tools = toolkit.getTools();

// Use with generateText or streamText
import { generateText } from 'ai';
const result = await generateText({
  model: yourModel,
  tools,
  prompt: 'Schedule a meeting tomorrow at 2pm on my work calendar',
});
```

### OpenAI Function Calling

```typescript
import { ChronaryToolkit } from '@chronary/toolkit/openai';

const toolkit = new ChronaryToolkit({ apiKey: process.env.CHRONARY_API_KEY });
const tools = toolkit.getTools();

// Returns OpenAI-formatted function definitions
// Use with openai.chat.completions.create({ tools })
```

### LangChain

```typescript
import { ChronaryToolkit } from '@chronary/toolkit/langchain';

const toolkit = new ChronaryToolkit({ apiKey: process.env.CHRONARY_API_KEY });
const tools = toolkit.getTools();

// Returns LangChain StructuredTool instances
// Use with AgentExecutor or tool-calling chains
```

### Mastra

```typescript
import { ChronaryToolkit } from '@chronary/toolkit/mastra';

const toolkit = new ChronaryToolkit({ apiKey: process.env.CHRONARY_API_KEY });
const tools = toolkit.getTools();

// Returns Mastra-compatible tool definitions
```

### MCP (Model Context Protocol)

```typescript
import { ChronaryToolkit } from '@chronary/toolkit/mcp';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

const server = new McpServer({ name: 'chronary', version: '1.0.0' });
const toolkit = new ChronaryToolkit({ apiKey: process.env.CHRONARY_API_KEY });
toolkit.registerAll(server);
```

## Selective Tool Loading

Load only the tools you need:

```typescript
const toolkit = new ChronaryToolkit({
  apiKey: process.env.CHRONARY_API_KEY,
  tools: ['list_calendars', 'create_event', 'check_availability'],
});
```

## Error Handling

All tools return a structured result:

```typescript
// Success
{ result: { id: 'cal_...', name: 'Work', ... }, isError: false }

// Error
{ result: { error: { type: 'not_found', message: '...' } }, isError: true }
```

Tools never throw — they return `isError: true` with details. This is safe for agent loops.
