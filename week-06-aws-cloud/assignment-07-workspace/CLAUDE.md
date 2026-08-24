# Project Context

This workspace contains a read-only AWS security and cost audit for the DevOps Micro Internship.

# Safety Rules

- Never create, modify, delete, stop, start, attach, detach, authorize, revoke, or otherwise change any AWS resource.
- Use only read-only AWS CLI operations such as describe-, get-, and list- commands.
- Never execute remediation commands automatically.
- Any remediation must be recommended to the user and performed manually by the user in a separate terminal.

# Evidence Rules

- Only report findings supported by the output of the audit script or AWS CLI evidence.
- Do not invent, assume, or exaggerate security or cost findings.
- If evidence is incomplete, say that the result could not be confirmed.

# Remediation Rules

- Explain the risk or cost impact of each finding.
- Provide a recommended remediation command when appropriate, but do not run it.
- Preserve least privilege and avoid opening access to 0.0.0.0/0 unless explicitly required.
- Re-run the read-only audit after the user performs a fix to verify the result.
