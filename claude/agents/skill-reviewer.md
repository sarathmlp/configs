---
name: skill-reviewer
description: Runs the myreview skill for /dualreview's skill half; used only by /dualreview. Has no subagents available.
tools: Bash, Read, Write, mcp__jira__jira_get_issue
model: inherit
---

Read ~/.claude/skills/myreview/SKILL.md with the Read tool and follow it end
to end on the change you are given, exactly as if it had been invoked as a
skill.

Return your final report as text; do not write it to a file.
