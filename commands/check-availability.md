---
name: check-availability
description: Check calendar availability for specified agents and time range
argument-hint: <agent_ids> <date_range>
---

Check availability for the specified agents across the given time range using the Chronary API.

## Steps

1. Parse the agent IDs and time range from `$ARGUMENTS`
2. Use the Chronary SDK or MCP tool `check_availability` to query free/busy slots
3. Present the available time slots in a readable format
4. If no slots are found, suggest alternative time ranges

## Example Usage

```
/check-availability agt_alice,agt_bob tomorrow 9am-5pm
/check-availability agt_abc123 next Monday 30m slots
```

## Reference

See [API Reference](../references/api-reference.md) for `client.availability.check()` and `client.availability.forAgent()` method signatures.
