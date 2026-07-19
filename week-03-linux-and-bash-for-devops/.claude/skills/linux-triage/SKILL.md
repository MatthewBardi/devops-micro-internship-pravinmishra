---
name: linux-triage
description: Run read-only Linux and Nginx health checks, analyze the evidence, and recommend a human-approved recovery action.
disable-model-invocation: true
allowed-tools: Bash(./scripts/linux-triage.sh) Read Grep
disallowed-tools: Write Edit NotebookEdit
---

# Linux Triage Workflow

1. Run `./scripts/linux-triage.sh` from the project root.
2. Read `reports/latest-report.txt`.
3. Report the operator's name and overall health status.
4. Summarize the evidence from all five checks.
5. Identify warnings and failures only when supported by the report.
6. Explain the most likely cause using the collected evidence.
7. When recovery is required, suggest the exact command for the human operator to run.
8. Never execute a recovery command.

# Safety Rules

- Perform read-only investigation only.
- Do not create, edit, overwrite, move, or delete files.
- Do not start, stop, restart, enable, or disable any service.
- Do not run `sudo` or make system configuration changes.
- Do not claim that recovery succeeded until the skill is run again and healthy evidence is collected.
- The human operator must approve and execute every recovery action.

# Output Format

Display the results using these headings:

- Operator
- Overall Status
- Evidence
- Most Likely Cause
- Suggested Human Action
- Verification Required
