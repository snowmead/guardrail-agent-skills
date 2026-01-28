---
name: guardrail
description: Analyze project and recommend prek pre-commit hooks
allowed-tools: [Skill, Task, Read, Grep, Glob, WebSearch, WebFetch, AskUserQuestion]
---

# /guardrail Command

Immediately invoke the guardrail-commit-hooks-skill using the Skill tool:

- skill: "commit-guardrails:guardrail-commit-hooks-skill"
- args: "analyze $ARGUMENTS"

The skill will analyze the project and recommend appropriate hooks.
