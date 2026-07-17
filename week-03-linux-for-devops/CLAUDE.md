# Project Overview

This project belongs to Matthew Bardi and performs read-only Linux and Nginx incident triage. It gathers evidence about service status, port 80, HTTP response, disk usage, and memory usage.

# Incident Workflow

Follow the Agentic Loop:

1. Gather evidence with read-only commands.
2. Analyze only the collected evidence.
3. Suggest a recovery command for the human operator.
4. Wait for the human to execute the recovery.
5. Verify the system again after recovery.

# Safety Rules

- Do not start, stop, restart, reload, or modify any service.
- Do not create, edit, move, or delete system files.
- Do not execute recovery commands.
- Do not expose credentials, keys, tokens, account IDs, or sensitive data.
- Do not diagnose a cause unless the collected evidence supports it.
- The human operator must approve and execute every recovery action.

# Output Rules

- Show the result of every health check.
- Label each result as HEALTHY, WARN, or FAIL.
- Separate confirmed evidence from assumptions.
- State the most likely cause only when supported by evidence.
- Suggest one safe recovery command, but do not execute it.
- End with a concise overall status and recommended next step.
