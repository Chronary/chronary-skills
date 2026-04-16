# Chronary Webhook Events

Chronary delivers webhook events via HTTP POST to your registered URL. All payloads are signed with HMAC-SHA256.

## Event Types

| Event | Trigger |
|-------|---------|
| `agent.created` | New agent created |
| `agent.updated` | Agent name, description, status, or metadata changed |
| `event.created` | New event created on a calendar |
| `event.updated` | Event title, times, status, or metadata changed |
| `event.deleted` | Event soft-deleted |
| `event.started` | Event start time reached (time-triggered) |
| `event.ended` | Event end time reached (time-triggered) |
| `proposal.created` | Scheduling proposal created |
| `proposal.responded` | Agent responded to a scheduling proposal |
| `proposal.confirmed` | Proposal accepted and event created |
| `proposal.expired` | Proposal expired without resolution |
| `proposal.cancelled` | Proposal cancelled by organizer |

## Payload Format

Every webhook delivery includes:

```json
{
  "type": "event.created",
  "data": {
    "id": "evt_abc123",
    "calendar_id": "cal_def456",
    "org_id": "org_ghi789",
    "title": "Team Standup",
    "start_time": "2026-04-16T09:00:00Z",
    "end_time": "2026-04-16T09:30:00Z",
    "status": "confirmed",
    "created_at": "2026-04-15T20:00:00Z",
    "updated_at": "2026-04-15T20:00:00Z"
  }
}
```

## Headers

| Header | Description |
|--------|-------------|
| `X-Signature` | HMAC-SHA256 signature: `sha256=<hex>` |
| `X-Timestamp` | Unix timestamp (seconds) when the payload was signed |
| `Content-Type` | `application/json` |

## Signature Verification

The signature is computed over `{timestamp}.{rawBody}` using the webhook's signing secret (`whsec_...`).

### TypeScript SDK

```typescript
import Chronary from '@chronary/sdk';

// Verify + parse in one call
const event = await Chronary.webhooks.constructEvent(
  rawBody,           // raw request body string
  request.headers,   // Headers object or Record<string, string>
  'whsec_...',       // signing secret from webhook creation
);

console.log(event.type); // 'event.created'
console.log(event.data); // event payload
```

### Manual Verification

```typescript
import crypto from 'node:crypto';

function verify(rawBody: string, headers: Record<string, string>, secret: string): boolean {
  const signature = headers['x-signature'];
  const timestamp = headers['x-timestamp'];

  // Check timestamp is within 5 minutes
  const age = Math.abs(Date.now() - parseInt(timestamp) * 1000);
  if (age > 5 * 60 * 1000) return false;

  // Compute expected signature
  const expected = 'sha256=' + crypto
    .createHmac('sha256', secret)
    .update(`${timestamp}.${rawBody}`)
    .digest('hex');

  return crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(signature));
}
```

## Example Payloads

### agent.created

```json
{
  "type": "agent.created",
  "data": {
    "id": "agt_abc123",
    "org_id": "org_ghi789",
    "name": "Support Bot",
    "type": "ai",
    "status": "active",
    "description": "Customer support scheduling assistant",
    "metadata": {},
    "created_at": "2026-04-15T20:00:00Z",
    "updated_at": "2026-04-15T20:00:00Z"
  }
}
```

### event.created

```json
{
  "type": "event.created",
  "data": {
    "id": "evt_def456",
    "calendar_id": "cal_abc123",
    "org_id": "org_ghi789",
    "title": "Team Standup",
    "description": "Daily sync meeting",
    "start_time": "2026-04-16T09:00:00Z",
    "end_time": "2026-04-16T09:30:00Z",
    "all_day": false,
    "status": "confirmed",
    "source": "internal",
    "metadata": {},
    "created_at": "2026-04-15T20:00:00Z",
    "updated_at": "2026-04-15T20:00:00Z"
  }
}
```

### event.started

```json
{
  "type": "event.started",
  "data": {
    "id": "evt_def456",
    "calendar_id": "cal_abc123",
    "org_id": "org_ghi789",
    "title": "Team Standup",
    "start_time": "2026-04-16T09:00:00Z",
    "end_time": "2026-04-16T09:30:00Z",
    "status": "confirmed"
  }
}
```

### proposal.created

```json
{
  "type": "proposal.created",
  "data": {
    "id": "prp_abc123",
    "org_id": "org_ghi789",
    "organizer_agent_id": "agt_abc123",
    "title": "Quarterly Planning",
    "proposed_times": [
      { "start": "2026-04-17T14:00:00Z", "end": "2026-04-17T15:00:00Z" },
      { "start": "2026-04-18T10:00:00Z", "end": "2026-04-18T11:00:00Z" }
    ],
    "invitee_agent_ids": ["agt_def456", "agt_ghi789"],
    "status": "pending",
    "expires_at": "2026-04-16T20:00:00Z",
    "created_at": "2026-04-15T20:00:00Z"
  }
}
```

### proposal.confirmed

```json
{
  "type": "proposal.confirmed",
  "data": {
    "id": "prp_abc123",
    "org_id": "org_ghi789",
    "status": "confirmed",
    "confirmed_time": {
      "start": "2026-04-17T14:00:00Z",
      "end": "2026-04-17T15:00:00Z"
    },
    "event_id": "evt_xyz789",
    "calendar_id": "cal_abc123"
  }
}
```

## Delivery Behavior

- Payloads are delivered via HTTP POST with a 10-second timeout
- Failed deliveries are retried with exponential backoff (3 attempts)
- Webhooks are automatically deactivated after sustained failures
- Delivery order is not guaranteed — use timestamps for ordering
