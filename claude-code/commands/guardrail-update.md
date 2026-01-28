---
name: guardrail-update
description: Update existing prek hooks to latest versions
allowed-tools: [Skill, Task, Read, Edit, Bash, WebSearch, WebFetch, AskUserQuestion]
---

# /guardrail:update Command

Immediately invoke the guardrail-commit-hooks-skill using the Skill tool:

- skill: "commit-guardrails:guardrail-commit-hooks-skill"
- args: "update $ARGUMENTS"

The skill will update hooks to their latest versions.
