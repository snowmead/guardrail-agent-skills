---
name: guardrail-setup
description: Full setup wizard - install prek, create config, run hooks
allowed-tools: [Skill, Task, Read, Grep, Glob, Bash, Write, WebSearch, WebFetch, AskUserQuestion]
---

# /guardrail:setup Command

Immediately invoke the guardrail-commit-hooks-skill using the Skill tool:

- skill: "commit-guardrails:guardrail-commit-hooks-skill"
- args: "setup $ARGUMENTS"

The skill will guide through full prek installation and configuration.
