# Terraform Drift Review Summary

**Full Name:** Matthew Bardi

## 1. Change Introduced

I introduced a controlled Terraform configuration change by adding the following temporary tag to the existing AWS security group:

`DriftReviewTest = "controlled-difference"`

The change was made only in the Terraform configuration and was not applied to AWS.

## 2. Evidence Collected

The drift-check workflow collected evidence using `terraform plan -detailed-exitcode`.

During the controlled-change test:

- Terraform returned detailed exit code `2`, proving that a pending change existed.
- The plan showed an in-place update to the security group for the temporary tag.
- No delete or replacement actions were detected.
- The policy check also detected an existing SSH rule allowing port 22 from `0.0.0.0/0`.
- The generated `drift-detected-report.txt` returned `Overall Status: FAIL`.

Claude reviewed the same evidence through the `/tf-drift-review` Skill and explained the difference and associated risk.

## 3. Risk Assessment

The temporary tag itself was a low-risk Terraform configuration change.

However, the review also identified that the existing security group allows SSH on port 22 from `0.0.0.0/0`. This exposes SSH access to the public internet and requires human review.

The unsafe SSH rule was already present and was not created by the controlled test change.

## 4. Human-Approved Action

I reviewed the Terraform plan and chose not to apply the temporary controlled change.

I manually removed the `DriftReviewTest = "controlled-difference"` tag from `main.tf`.

No `terraform apply` or `terraform destroy` command was used to resolve the controlled difference.

## 5. Verification

After removing the temporary tag, I ran the drift review again.

The final evidence showed:

- Terraform detailed exit code: `0`
- No pending Terraform changes
- No delete or replacement actions in the pending plan
- Final review status: `HEALTHY`

The final clean result was saved as `resolved-report.txt`.

The `HEALTHY` status confirms that the Terraform configuration, state, and deployed resources are aligned under the current drift-check workflow. It does not by itself prove that every existing security rule is secure because the ingress policy check evaluates planned changes.

## 6. Safety Decision

The workflow kept infrastructure-changing actions under human control.

The `/tf-drift-review` Skill gathered and interpreted evidence without applying changes.

A `PreToolUse` safety hook was also configured to block `terraform apply` through Claude Code whenever the latest drift report contains:

`Overall Status: FAIL`

The hook was successfully tested and blocked the apply attempt.

## 7. Agentic Loop Mapping

**Observe:** Terraform and the Bash script collected current plan evidence.

**Analyze:** Claude reviewed the generated reports, plan evidence, destructive-action checks, and ingress findings.

**Recommend:** Claude explained the risk and recommended human review instead of automatically applying the change.

**Human Decision:** I reviewed the evidence and chose to remove the temporary test tag rather than apply it.

**Act:** I manually removed the controlled Terraform configuration change.

**Verify:** I ran `/tf-drift-review` again and confirmed the final result was `HEALTHY`.

This workflow combines deterministic Terraform evidence collection, AI-assisted reasoning, human approval, and post-change verification.