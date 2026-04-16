---
name: schedule-event
description: Schedule a new event on a Chronary calendar with optional availability checking
argument-hint: <title> <calendar_id> <start_time> <end_time>
---

Schedule a new event on a Chronary calendar. Optionally checks availability first to avoid conflicts.

## Steps

1. Parse event details from `$ARGUMENTS`
2. If an agent is associated with the calendar, check availability first using `check_availability`
3. If the time slot is free, create the event using `create_event`
4. If there's a conflict, show the busy blocks and suggest alternative times
5. Display the created event details

## Example Usage

```
/schedule-event "Team Standup" cal_def456 2026-04-16T09:00:00Z 2026-04-16T09:30:00Z
/schedule-event "Client Call" cal_def456 tomorrow 2pm-3pm
/schedule-event "Planning" cal_def456 next Monday 10am 1 hour
```

## Reference

See [API Reference](../references/api-reference.md) for `client.events.create()` and [Examples](../references/examples.md) for conflict detection patterns.
