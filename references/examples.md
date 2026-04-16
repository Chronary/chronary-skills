# Chronary Code Examples

Comprehensive examples using the `@chronary/sdk` TypeScript SDK.

## Setup

```typescript
import Chronary from '@chronary/sdk';

const client = new Chronary({ apiKey: process.env.CHRONARY_API_KEY });
```

## Basic CRUD — Agents

```typescript
// Create an AI agent
const agent = await client.agents.create({
  name: 'Scheduling Assistant',
  type: 'ai',
  description: 'Manages meeting schedules for the engineering team',
});
console.log(agent.id); // agt_...

// List active AI agents
for await (const a of client.agents.list({ type: 'ai', status: 'active' })) {
  console.log(a.name);
}

// Pause an agent
await client.agents.update(agent.id, { status: 'paused' });

// Delete an agent
await client.agents.delete(agent.id);
```

## Calendar Management

```typescript
// Create a calendar for an agent
const calendar = await client.calendars.create({
  name: 'Work Schedule',
  timezone: 'America/New_York',
  agentId: agent.id,
});
console.log(calendar.ical_url); // Public iCal feed URL

// Create a standalone (shared) calendar
const shared = await client.calendars.create({
  name: 'Conference Rooms',
  timezone: 'UTC',
});

// List all calendars for an agent
for await (const cal of client.calendars.list({ agentId: agent.id })) {
  console.log(`${cal.name} (${cal.timezone})`);
}
```

## Event Scheduling

```typescript
// Create an event
const event = await client.events.create(calendar.id, {
  title: 'Team Standup',
  start_time: '2026-04-16T09:00:00-04:00',
  end_time: '2026-04-16T09:30:00-04:00',
  description: 'Daily sync meeting',
  metadata: { recurring: true, meeting_link: 'https://meet.example.com/standup' },
});

// Create an all-day event
await client.events.create(calendar.id, {
  title: 'Company Holiday',
  start_time: '2026-07-04T00:00:00Z',
  end_time: '2026-07-05T00:00:00Z',
  all_day: true,
});

// List upcoming events
for await (const evt of client.events.list({
  calendarId: calendar.id,
  start_after: new Date().toISOString(),
  status: 'confirmed',
})) {
  console.log(`${evt.title}: ${evt.startTime} - ${evt.endTime}`);
}

// Cancel an event
await client.events.update(calendar.id, event.id, { status: 'cancelled' });
```

## Availability Queries

### Single Agent

```typescript
const tomorrow = new Date();
tomorrow.setDate(tomorrow.getDate() + 1);
tomorrow.setHours(8, 0, 0, 0);

const dayEnd = new Date(tomorrow);
dayEnd.setHours(18, 0, 0, 0);

const availability = await client.availability.forAgent(agent.id, {
  start: tomorrow.toISOString(),
  end: dayEnd.toISOString(),
  slot_duration: '30m',
});

console.log(`Found ${availability.slots.length} available 30-minute slots:`);
for (const slot of availability.slots) {
  console.log(`  ${slot.start} — ${slot.end}`);
}
```

### Cross-Agent (Find Mutual Free Time)

```typescript
const mutual = await client.availability.check({
  agents: ['agt_alice', 'agt_bob', 'agt_carol'],
  start: '2026-04-17T08:00:00Z',
  end: '2026-04-17T18:00:00Z',
  slot_duration: '1h',
  include_busy: true,
});

console.log('Mutual free slots:', mutual.slots);
console.log('Alice busy blocks:', mutual.per_agent_busy?.['agt_alice']);
```

### Calendar-Level Availability

```typescript
const calAvailability = await client.availability.forCalendar(calendar.id, {
  start: '2026-04-16T00:00:00Z',
  end: '2026-04-23T00:00:00Z',
  slot_duration: '45m',
});
```

## Webhook Setup and Verification

### Create a Webhook

```typescript
const webhook = await client.webhooks.create({
  url: 'https://myapp.example.com/webhooks/chronary',
  events: ['event.created', 'event.updated', 'event.deleted', 'event.started'],
});

// IMPORTANT: Save the secret — it's only returned on creation
console.log('Webhook secret:', webhook.secret); // whsec_...
```

### Verify Incoming Webhooks (Express)

```typescript
import express from 'express';
import Chronary from '@chronary/sdk';

const app = express();

app.post('/webhooks/chronary', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const event = await Chronary.webhooks.constructEvent(
      req.body.toString(),
      req.headers as Record<string, string>,
      process.env.CHRONARY_WEBHOOK_SECRET!,
    );

    switch (event.type) {
      case 'event.created':
        console.log('New event:', event.data);
        break;
      case 'event.started':
        console.log('Event starting now:', event.data);
        // Send notification, trigger workflow, etc.
        break;
    }

    res.sendStatus(200);
  } catch (err) {
    console.error('Webhook verification failed:', err);
    res.sendStatus(400);
  }
});
```

## iCal Feed Sync

### Subscribe to an External Calendar

```typescript
// Import a Google Calendar
const sub = await client.icalSubscriptions.create(agent.id, {
  calendar_id: calendar.id,
  url: 'https://calendar.google.com/calendar/ical/user%40gmail.com/basic.ics',
  label: 'Personal Google Calendar',
});

// Events will sync every 15 minutes automatically
console.log(`Subscription status: ${sub.status}`); // 'active'

// Trigger an immediate sync
await client.icalSubscriptions.sync(sub.id);

// Check sync status
const updated = await client.icalSubscriptions.get(sub.id);
console.log(`Last synced: ${updated.lastSyncedAt}`);
if (updated.lastError) {
  console.error(`Sync error: ${updated.lastError}`);
}
```

### Expose a Calendar as an iCal Feed

```typescript
// Every calendar has a public iCal feed URL (no auth required)
const cal = await client.calendars.get(calendar.id);
console.log(`Add to Google Calendar: ${cal.ical_url}`);
// https://api.chronary.ai/ical/{token}
```

## Multi-Agent Calendar Management

```typescript
// Create agents for a team
const alice = await client.agents.create({ name: 'Alice', type: 'human' });
const bob = await client.agents.create({ name: 'Bob', type: 'human' });
const roomA = await client.agents.create({ name: 'Room A', type: 'resource' });

// Create calendars
const aliceCal = await client.calendars.create({ name: 'Alice Schedule', timezone: 'America/New_York', agentId: alice.id });
const bobCal = await client.calendars.create({ name: 'Bob Schedule', timezone: 'America/Chicago', agentId: bob.id });
const roomCal = await client.calendars.create({ name: 'Room A', timezone: 'America/New_York', agentId: roomA.id });

// Find a time when Alice, Bob, and Room A are all free
const slots = await client.availability.check({
  agents: [alice.id, bob.id, roomA.id],
  start: '2026-04-17T13:00:00Z',
  end: '2026-04-17T21:00:00Z',
  slot_duration: '1h',
});

if (slots.slots.length > 0) {
  const slot = slots.slots[0];
  // Book the meeting on Alice's calendar
  await client.events.create(aliceCal.id, {
    title: 'Planning Meeting with Bob',
    start_time: slot.start,
    end_time: slot.end,
    metadata: { room: roomA.id, attendees: [alice.id, bob.id] },
  });
}
```

## Conflict Detection

```typescript
// Check if a specific time slot is free before booking
const proposed = {
  start: '2026-04-16T14:00:00Z',
  end: '2026-04-16T15:00:00Z',
};

const check = await client.availability.forAgent(agent.id, {
  start: proposed.start,
  end: proposed.end,
  slot_duration: '1h',
  include_busy: true,
});

if (check.slots.length > 0) {
  // Slot is free — book it
  await client.events.create(calendar.id, {
    title: 'Client Call',
    start_time: proposed.start,
    end_time: proposed.end,
  });
} else {
  // Conflict — show what's blocking
  const busy = check.per_agent_busy?.[agent.id] ?? [];
  console.log('Time is blocked by:', busy);
}
```

## Usage Monitoring

```typescript
const usage = await client.usage.get();

console.log(`Plan: ${usage.plan}`);
console.log(`Events: ${usage.events.used}/${usage.events.limit ?? 'unlimited'}`);
console.log(`API calls: ${usage.api_calls.used}/${usage.api_calls.limit ?? 'unlimited'}`);

// Warn if approaching limits
for (const [resource, metric] of Object.entries(usage)) {
  if (typeof metric === 'object' && metric.limit && metric.used / metric.limit > 0.8) {
    console.warn(`Warning: ${resource} at ${Math.round(metric.used / metric.limit * 100)}% of quota`);
  }
}
```

## Error Handling

```typescript
import { NotFoundError, RateLimitError, QuotaExceededError, ValidationError } from '@chronary/sdk';

async function safeGetAgent(id: string) {
  try {
    return await client.agents.get(id);
  } catch (err) {
    if (err instanceof NotFoundError) {
      return null; // Agent doesn't exist
    }
    if (err instanceof RateLimitError) {
      // Wait and retry
      await new Promise(r => setTimeout(r, (err.retryAfter ?? 1) * 1000));
      return client.agents.get(id);
    }
    if (err instanceof QuotaExceededError) {
      throw new Error('Monthly quota exceeded — upgrade plan at console.chronary.ai');
    }
    throw err; // Re-throw unexpected errors
  }
}
```
