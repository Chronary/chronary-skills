# Chronary SDK API Reference

Complete TypeScript method signatures for `@chronary/sdk`.

```bash
npm install @chronary/sdk
```

```typescript
import Chronary from '@chronary/sdk';

const client = new Chronary({ apiKey: 'chr_sk_live_...' });
```

## Configuration

```typescript
interface ChronaryConfig {
  apiKey?: string;          // Required. Falls back to CHRONARY_API_KEY env var
  baseUrl?: string;         // Default: 'https://api.chronary.ai'
  timeout?: number;         // Default: 30000 (ms)
  maxRetries?: number;      // Default: 2 (retries on 408, 429, 5xx)
  logLevel?: LogLevel;      // 'debug' | 'info' | 'warn' | 'error' | 'off'
  fetch?: typeof fetch;     // Custom fetch (for Cloudflare Workers, test mocking)
  appInfo?: { name: string; version?: string };
}
```

## Agents — `client.agents`

```typescript
// Create an agent
client.agents.create(params: CreateAgentParams): Promise<Agent>
// params: { name: string, type: 'ai' | 'human' | 'resource', description?: string, metadata?: Record<string, unknown> }

// Get agent by ID
client.agents.get(id: string): Promise<Agent>

// List agents (returns async iterator)
client.agents.list(params?: ListAgentsParams): PageIterator<Agent>
// params: { type?: 'ai' | 'human' | 'resource', status?: 'active' | 'paused' | 'decommissioned', limit?: number, offset?: number }

// Update agent
client.agents.update(id: string, params: UpdateAgentParams): Promise<Agent>
// params: { name?: string, description?: string | null, metadata?: Record<string, unknown>, status?: 'active' | 'paused' }

// Delete agent (soft-delete)
client.agents.delete(id: string): Promise<void>
```

## Calendars — `client.calendars`

```typescript
// Create a calendar (optionally scoped to an agent)
client.calendars.create(params: CreateCalendarParams & { agentId?: string }): Promise<Calendar>
// params: { name: string, timezone: string, metadata?: Record<string, unknown>, agentId?: string }

// Get calendar by ID
client.calendars.get(id: string): Promise<Calendar>

// List calendars
client.calendars.list(params?: ListCalendarsParams): PageIterator<Calendar>
// params: { agentId?: string, include?: 'all', limit?: number, offset?: number }

// Update calendar
client.calendars.update(id: string, params: UpdateCalendarParams): Promise<Calendar>
// params: { name?: string, timezone?: string, metadata?: Record<string, unknown> }

// Delete calendar (soft-delete)
client.calendars.delete(id: string): Promise<void>
```

## Events — `client.events`

```typescript
// Create an event on a calendar
client.events.create(calendarId: string, params: CreateEventParams): Promise<CalendarEvent>
// params: { title: string, start_time: string, end_time: string, description?: string, all_day?: boolean, status?: 'confirmed' | 'tentative' | 'cancelled', metadata?: Record<string, unknown> }

// Get event by calendar ID + event ID
client.events.get(calendarId: string, eventId: string): Promise<CalendarEvent>

// List events (requires calendarId or agentId)
client.events.list(params: ListEventsParams): PageIterator<CalendarEvent>
// params: { calendarId?: string, agentId?: string, start_after?: string, start_before?: string, status?: 'confirmed' | 'tentative' | 'cancelled', source?: 'internal' | 'external_ical', limit?: number, offset?: number }

// Update event
client.events.update(calendarId: string, eventId: string, params: UpdateEventParams): Promise<CalendarEvent>
// params: { title?: string, description?: string | null, start_time?: string, end_time?: string, all_day?: boolean, status?: 'confirmed' | 'tentative' | 'cancelled', metadata?: Record<string, unknown> }

// Delete event (soft-delete)
client.events.delete(calendarId: string, eventId: string): Promise<void>
```

## Availability — `client.availability`

```typescript
// Single agent availability
client.availability.forAgent(agentId: string, params: AvailabilityParams): Promise<AvailabilityResponse>

// Single calendar availability
client.availability.forCalendar(calendarId: string, params: AvailabilityParams): Promise<AvailabilityResponse>

// Cross-agent availability (find mutual free time)
client.availability.check(params: CrossAgentAvailabilityParams): Promise<AvailabilityResponse>
```

```typescript
interface AvailabilityParams {
  start: string;                  // ISO 8601 datetime
  end: string;                    // ISO 8601 datetime
  slot_duration?: SlotDuration;   // '15m' | '30m' | '45m' | '1h' | '2h'
  include_busy?: boolean;         // Include busy block details
}

interface CrossAgentAvailabilityParams extends AvailabilityParams {
  agents: string[];               // Agent IDs to intersect
  calendars?: string[];           // Optional calendar filter
}

interface AvailabilityResponse {
  agents: string[];
  slots: AvailabilitySlot[];                  // { start: string, end: string }
  per_agent_busy?: Record<string, BusyBlock[]>; // Only when include_busy=true
}
```

## Webhooks — `client.webhooks`

```typescript
// Create webhook (response includes signing secret)
client.webhooks.create(params: CreateWebhookParams): Promise<Webhook>
// params: { url: string, events: string[] }

// Get webhook by ID
client.webhooks.get(id: string): Promise<Webhook>

// List webhooks
client.webhooks.list(params?: ListWebhooksParams): PageIterator<Webhook>

// Update webhook
client.webhooks.update(id: string, params: UpdateWebhookParams): Promise<Webhook>
// params: { url?: string, events?: string[], active?: boolean }

// Delete webhook
client.webhooks.delete(id: string): Promise<void>
```

### Webhook Signature Verification

```typescript
// Verify and parse a webhook payload
const event = await Chronary.webhooks.constructEvent(
  rawBody,    // string — raw request body (not parsed JSON)
  headers,    // Headers or Record<string, string>
  secret,     // whsec_... signing secret from webhook creation
);

// Or verify only (throws on failure)
await Chronary.webhooks.verifySignature(rawBody, headers, secret);
```

## iCal Subscriptions — `client.icalSubscriptions`

```typescript
// Create subscription (import external calendar)
client.icalSubscriptions.create(agentId: string, params: CreateICalSubscriptionParams): Promise<ICalSubscription>
// params: { calendar_id: string, url: string, label?: string }

// Get subscription by ID
client.icalSubscriptions.get(id: string): Promise<ICalSubscription>

// List subscriptions for an agent
client.icalSubscriptions.list(params: ListICalSubscriptionsParams & { agentId: string }): PageIterator<ICalSubscription>
// params: { agentId: string, status?: 'active' | 'error' | 'paused', limit?: number, offset?: number }

// Update subscription
client.icalSubscriptions.update(id: string, params: UpdateICalSubscriptionParams): Promise<ICalSubscription>
// params: { label?: string, url?: string }

// Delete subscription
client.icalSubscriptions.delete(id: string): Promise<void>

// Trigger immediate sync
client.icalSubscriptions.sync(id: string): Promise<{ status: string }>
```

## Usage — `client.usage`

```typescript
client.usage.get(): Promise<Usage>

interface Usage {
  period_start: string;
  period_end: string;
  plan: string;
  agents: UsageMetric;               // { used: number, limit: number | null }
  calendars: UsageMetric;
  events: UsageMetric;
  api_calls: UsageMetric;
  webhooks: UsageMetric;
  availability_queries: UsageMetric;
  ical_subscriptions: UsageMetric;
}
```

## Pagination

List methods return a `PageIterator` that supports async iteration:

```typescript
// Iterate all pages automatically
for await (const agent of client.agents.list()) {
  console.log(agent.name);
}

// Or get a single page
const page = await client.agents.list({ limit: 10 }).getPage();
console.log(page.data);     // Agent[]
console.log(page.total);    // total count
console.log(page.hasMore);  // boolean
```

## Error Handling

```typescript
import { ChronaryError, AuthenticationError, RateLimitError, NotFoundError, ValidationError, QuotaExceededError } from '@chronary/sdk';

try {
  await client.agents.get('agt_nonexistent');
} catch (err) {
  if (err instanceof NotFoundError) {
    // 404 — resource not found
  } else if (err instanceof RateLimitError) {
    // 429 — retry after err.retryAfter seconds
  } else if (err instanceof QuotaExceededError) {
    // 402/429 — monthly quota exceeded
  } else if (err instanceof AuthenticationError) {
    // 401 — bad API key
  } else if (err instanceof ValidationError) {
    // 422 — invalid request
  }
}
```

All errors include `err.status`, `err.message`, `err.requestId`, and `err.headers`.
