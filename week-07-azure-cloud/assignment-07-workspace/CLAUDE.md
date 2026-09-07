# Azure Security Posture Audit

## Project Overview

This workspace contains a read-only security audit for Azure resources deployed during Week 7 of the DevOps Micro Internship.

The audit covers:

- Azure Virtual Machines
- Network Security Groups and Load Balancer-related networking
- Azure Storage Accounts
- Azure Database for MySQL Flexible Server

The audit uses the Azure CLI (`az`) and must only inspect existing resources.

## Audit Workflow

1. Confirm Azure CLI authentication and resource visibility.
2. Run the read-only Bash audit script.
3. Review the generated PASS, WARN, and FAIL findings.
4. Explain each finding using only evidence from the audit report.
5. Recommend a remediation command when appropriate.
6. Never run the remediation automatically.
7. The human operator must review and run any remediation command manually.
8. Run the audit again after remediation to confirm whether the finding was resolved.

## Required Security Checks

The audit must check:

1. NSG rules that allow port 22 or 3389 from `0.0.0.0/0`.
2. Storage Account public blob access configuration.
3. Azure VM disk encryption status.
4. Azure Database for MySQL public network access.

## Safety Rules

- NEVER run any mutating Azure CLI command.
- NEVER create, update, delete, enable, disable, restart, stop, start, or modify an Azure resource.
- Use only read-only Azure CLI commands such as `show`, `list`, and equivalent inspection commands.
- NEVER run a remediation command on behalf of the user.
- NEVER claim a security finding unless the audit report contains evidence supporting it.
- Clearly distinguish PASS, WARN, and FAIL findings.
- Do not expose subscription IDs, tenant IDs, client secrets, passwords, connection strings, tokens, or other credentials.
- Any remediation command must be presented only as a recommendation for human review.
- The human operator is responsible for approving and running all remediation commands.
- After a human-applied fix, verify the result using another read-only audit run.

## Agent Behavior

Claude must act as a read-only security reviewer.

Claude may:

- Read files in this workspace.
- Run the read-only audit script.
- Read and explain the generated audit report.
- Recommend remediation commands.

Claude must not:

- Modify Azure resources.
- Run remediation commands.
- Edit the audit report to change findings.
- Hide or downplay WARN or FAIL findings.
- Invent evidence that is not present in the audit output.
