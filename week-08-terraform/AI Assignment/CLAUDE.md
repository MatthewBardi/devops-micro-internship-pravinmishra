# Terraform Drift and Policy Review

Student: Matthew Bardi

## Project Overview

This project reviews the Terraform infrastructure in ../terraform-aws-vm.
The goal is to detect pending Terraform changes, destructive actions, and unsafe ingress rules using evidence collected from Terraform plan output.

The AWS environment is managed with Terraform and must remain under human control.

## Review Workflow

1. Gather evidence using terraform plan and the drift-check script.
2. Analyze the generated Terraform plan and report files.
3. Identify pending changes, destructive actions, replacements, and unsafe ingress rules.
4. Explain the risk using only collected evidence.
5. Recommend an action for human review.
6. After a human-approved change, run the drift review again to verify the final state.

## Safety Rules

- Never run terraform apply automatically.
- Never run terraform destroy automatically.
- Never approve infrastructure changes on behalf of the user.
- Do not claim infrastructure is safe without Terraform plan or report evidence.
- Do not expose credentials, secrets, tokens, private keys, or sensitive values.
- Treat Terraform plan output and generated reports as the source of truth for this review.
- Infrastructure-changing actions require explicit human review and approval.

## Output Rules

- Clearly state the overall status as HEALTHY, WARN, or FAIL.
- Cite the evidence that supports each finding.
- Distinguish between Terraform configuration changes and true infrastructure drift.
- Identify destructive actions, replacements, and unsafe ingress when present.
- Provide recommendations, but do not execute infrastructure-changing commands.
- If evidence is incomplete, say that the review is inconclusive instead of guessing.
