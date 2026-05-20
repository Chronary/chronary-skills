---
name: manage-calendar
description: Create, list, update, or delete Chronary calendars
argument-hint: <action> [options]
---

Manage Chronary calendars — create new calendars, list existing ones, update properties, or delete.

## Steps

1. Parse the action from `$ARGUMENTS` (create, list, get, update, delete)
2. Use the Chronary SDK or MCP tools to perform the operation
3. Display results in a readable format

## Example Usage

```
/manage-calendar create "Work Schedule" America/New_York --agent agt_abc123
/manage-calendar list
/manage-calendar list --agent agt_abc123
/manage-calendar update cal_def456 --timezone Europe/London
/manage-calendar delete cal_def456
```

When installed via the Claude Code plugin marketplace (`/plugin install chronary@chronary`), the command is namespaced — call it as `/chronary:manage-calendar` instead.

## Reference

See [API Reference](../references/api-reference.md) for `client.calendars.*` method signatures.
