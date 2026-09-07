---
name: azure-audit
description: Run and explain the Week 7 read-only Azure security posture audit.
allowed-tools: Bash, Read, Grep, Glob
---

# Azure Security Posture Audit

Run the local read-only Azure audit and explain its findings.

## Safety Rules

- This skill is READ-ONLY with respect to Azure.
- Never create, update, delete, start, stop, restart, enable, disable, or modify an Azure resource.
- Never run an Azure remediation command.
- Never use Write or Edit to alter audit evidence.
- Only explain findings supported by audit-report.txt.
- Never claim a PASS, WARN, or FAIL without report evidence.
- Never expose subscription IDs, tenant IDs, client secrets, passwords, tokens, connection strings, or storage keys.
- Any remediation command must be shown only as a recommendation for the human operator to review and run manually.

## Audit Procedure

1. Verify that azure-audit.sh exists in the current workspace.
2. Run:

   ./azure-audit.sh

3. Read audit-report.txt.
4. Explain each of these four checks:

   - NSG SSH/RDP exposure to 0.0.0.0/0
   - Storage Account public blob access
   - Azure VM disk encryption
   - MySQL Flexible Server public network access

5. For every finding, report:

   - Check name
   - PASS, WARN, or FAIL status
   - Evidence from the report
   - Security risk if unresolved
   - Recommended remediation when appropriate

## Remediation Rules

If a WARN or FAIL exists, remediation must be presented only for human review.

Use wording such as:

Recommended remediation — you must run this yourself. I have not executed it and will not execute it.

Never execute the proposed remediation.

For NSG exposure, never recommend leaving SSH or RDP open to 0.0.0.0/0. If access is required, recommend restricting the rule to the human operator's specific source IP/CIDR.

## Summary

Finish with:

- PASS count
- WARN count
- FAIL count
- Overall audit result
- The single highest-priority finding, if one exists

## Re-verification

After the human says they applied a remediation, run the read-only audit again and compare the new report with the previous findings.

Only claim that a finding is resolved when the new audit evidence proves it.
