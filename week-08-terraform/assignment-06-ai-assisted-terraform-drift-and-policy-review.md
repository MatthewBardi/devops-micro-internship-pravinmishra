# Assignment 6 — AI-Assisted Terraform Drift and Policy Review

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Student Details

**Full Name:** Matthew Bardi
**GitHub Repository/Folder URL:** https://github.com/MatthewBardi/devops-micro-internship-pravinmishra/tree/main/week-08-terraform

---

## Purpose

Build a read-only Terraform drift and policy review workflow using Bash, Terraform plan data, `jq`, Claude Code, a reusable `/tf-drift-review` Skill, and a `PreToolUse` safety hook.

The workflow must follow this pattern:

```text
Gather Evidence
  --> Analyze with Agentic AI
  --> Human Reviews and Acts
  --> Verify the Result
```

The `/tf-drift-review` Skill and `tf-drift-check.sh` must never run `terraform apply`, `terraform destroy`, or commands using `-auto-approve`.

---

# Task 1 — Confirm the Clean Baseline and Create the Workspace

## Goal

Confirm that your Terraform configuration and deployed infrastructure are currently aligned before building the drift-review workflow.

## Evidence

### Screenshot 1 — Clean Terraform Plan

Add a screenshot of `terraform plan` showing no pending changes.

![Screenshot 1](screenshots/week-08-assignment-06-screenshot-01-clean-terraform-plan.png)

---

### Screenshot 2 — Assignment Workspace

Add a screenshot of the folder structure showing `AI Assignment/`, `reports/`, and the Terraform project.

![Screenshot 2](screenshots/week-08-assignment-06-screenshot-02-assignment-workspace.png)

## Questions

### 1. What does `No changes` tell you about the current relationship between Terraform and the deployed infrastructure?

`No changes` means the Terraform configuration, Terraform state, and deployed AWS infrastructure are currently aligned. Terraform does not need to create, update, or destroy anything.

### 2. Why is a clean baseline important before introducing a test change?

A clean baseline gives me a known starting point. It ensures that any difference detected later can be linked to my controlled test instead of being confused with a pre-existing Terraform difference.

---

# Task 2 — Create Project Context and Safety Rules in `CLAUDE.md`

## Goal

Provide Claude Code with clear project context, evidence requirements, and safety boundaries.

## Evidence

### Screenshot 3 — Project Context and Safety Rules

Add a screenshot of `CLAUDE.md` open in VS Code showing the Project Overview, Review Workflow, Safety Rules, and Output Rules.

![Screenshot 3](screenshots/week-08-assignment-06-screenshot-03-claude-md-safety-rules.png)

## Questions

### 1. Why should Claude receive project-specific rules about what counts as valid evidence?

Claude needs project-specific rules so it knows which Terraform plans, generated reports, and other evidence are authoritative for this review. This prevents it from making unsupported assumptions about the infrastructure.

### 2. Why must the human remain responsible for running `terraform apply`?

The human must remain responsible for `terraform apply` because applying a plan can change or destroy real infrastructure. Claude may analyze and recommend, but infrastructure-changing decisions require explicit human review and approval.

### 3. Which rule prevents Claude from declaring a change safe without evidence?

The rule that prevents this is: `Do not claim infrastructure is safe without Terraform plan or report evidence.` It requires Claude to base conclusions on collected evidence rather than assumptions.

---

# Task 3 — Build the Terraform Drift and Policy Check Script

## Goal

Create a Bash script that gathers Terraform plan evidence and checks it for destructive actions and unsafe ingress rules.

## Evidence

### Screenshot 4 — Script Variables and Checks Array

Add a screenshot of the top section of `tf-drift-check.sh` showing the variables and `checks` array.

![Screenshot 4](screenshots/week-08-assignment-06-screenshot-04-script-variables-checks.png)

---

### Screenshot 5 — Destructive-Action and Open-Ingress Checks

Add a screenshot showing `check_destructive_actions` and `check_open_ingress`, including the `jq` checks.

![Screenshot 5](screenshots/week-08-assignment-06-screenshot-05-destructive-open-ingress-checks.png)

---

### Screenshot 6 — Script Validation and Permissions

Add a screenshot showing successful `bash -n` and `ls -l` output.

![Screenshot 6](screenshots/week-08-assignment-06-screenshot-06-script-validation-permissions.png)

## Questions

### 1. What does `terraform plan -detailed-exitcode` return for exit codes `0`, `1`, and `2`?

`terraform plan -detailed-exitcode` returns `0` when the plan succeeds and there are no changes, `1` when Terraform encounters an error, and `2` when the plan succeeds and changes are present.

### 2. Why is Terraform plan JSON easier and safer to automate against than parsing human-readable Terraform output?

Terraform plan JSON has a stable structured format that tools such as `jq` can query directly. Human-readable output is designed for people and can change formatting, making automated parsing less reliable and more error-prone.

### 3. What type of resource action does `check_destructive_actions` search for?

`check_destructive_actions` searches Terraform resource changes for the `delete` action.

### 4. Why does finding a `delete` action also help detect replacements?

Terraform replacements normally contain both a delete action and a create action. Therefore, detecting `delete` also helps identify resource replacements that would destroy an existing resource before or while creating another one.

### 5. Why must this script never run `terraform apply`?

The script must never run `terraform apply` because its purpose is read-only evidence collection and policy review. Applying changes must remain a separate human-controlled action.

---

# Task 4 — Run the Script Against the Clean Baseline

## Goal

Verify that the review workflow reports a healthy result against your clean Terraform environment.

## Evidence

### Screenshot 7 — Healthy Baseline Report

Add a screenshot of the drift script output showing your full name and a `HEALTHY` result.

![Screenshot 7](screenshots/week-08-assignment-06-screenshot-07-healthy-baseline-report.png)

---

### Screenshot 8 — Baseline Script Exit Code

Add a screenshot showing the captured script exit code `0`.

![Screenshot 8](screenshots/week-08-assignment-06-screenshot-08-baseline-exit-code.png)

## Questions

### 1. What is the Overall Status of your baseline?

The Overall Status of the clean baseline was `HEALTHY`.

### 2. Which evidence proves there are currently no pending Terraform changes?

The report showed `[PASS] Terraform plan: no pending changes` and Terraform returned detailed exit code `0`. Together these prove that Terraform detected no pending changes.

### 3. Was `reports/tfplan.json` created? Explain why or why not.

No. `reports/tfplan.json` was not created during the clean baseline because `terraform plan -detailed-exitcode` returned `0`. The script generates plan JSON only when Terraform returns exit code `2`, meaning changes need to be inspected.

---

# Task 5 — Create and Run the `/tf-drift-review` Claude Code Skill

## Goal

Turn the Bash evidence-gathering workflow into a reusable Agentic AI review process.

## Evidence

### Screenshot 9 — `/tf-drift-review` Skill Configuration

Add a screenshot of `SKILL.md` showing the frontmatter, allowed tools, and safety rules.

![Screenshot 9](screenshots/week-08-assignment-06-screenshot-09-tf-drift-review-skill.png)

---

### Screenshot 10 — Clean Agentic AI Review

Add a screenshot of `/tf-drift-review` showing the clean `HEALTHY` result.

![Screenshot 10](screenshots/week-08-assignment-06-screenshot-10-clean-agentic-ai-review.png)

## Questions

### 1. Why does this Skill have `Bash`, `Read`, and `Grep`, but not `Write`?

The Skill only needs `Bash`, `Read`, and `Grep` to run the read-only evidence script and inspect its results. `Write` is intentionally excluded so the Skill cannot modify Terraform configuration, state, reports, or infrastructure as part of its review.

### 2. Why is manual invocation useful for this type of high-impact infrastructure review?

Manual invocation is useful because infrastructure review can influence high-impact decisions. Requiring the user to explicitly invoke `/tf-drift-review` keeps the human in control of when the review occurs.

### 3. Which part of the workflow is deterministic Bash automation?

The deterministic Bash portion runs the drift-check script, executes `terraform plan`, captures the detailed exit code, generates evidence, and checks for destructive actions and unsafe ingress.

### 4. Which part requires Claude's reasoning?

Claude's reasoning is used to interpret the collected evidence, explain the significance and risk of the findings, distinguish a configuration change from true drift, and recommend a human-reviewed next action.

### 5. Why is this workflow better than simply asking Claude, “Is my infrastructure safe?”

This workflow is better because Claude reasons from reproducible Terraform evidence instead of guessing about the environment. The Bash checks provide deterministic facts first, and Claude then explains those facts while infrastructure-changing actions remain under human control.

---

# Task 6 — Introduce a Controlled Difference and Detect It

## Goal

Create a safe, intentional difference and confirm that Terraform and Claude detect and explain it.

## Evidence

### Screenshot 11 — Controlled Difference

Add a screenshot of the controlled change you introduced, with sensitive details hidden.

![Screenshot 11](screenshots/week-08-assignment-06-screenshot-11-controlled-difference.png)

---

### Screenshot 12 — Detected Difference and Risk Assessment

Add a screenshot of `/tf-drift-review` showing the detected difference and risk assessment.

![Screenshot 12](screenshots/week-08-assignment-06-screenshot-12-detected-difference-risk-assessment.png)

---

### Screenshot 13 — Detected Drift Report

Add a screenshot of `drift-detected-report.txt` showing your full name and the `WARN` or `FAIL` result.

![Screenshot 13](screenshots/week-08-assignment-06-screenshot-13-drift-detected-report.png)

## Questions

### 1. What change did you introduce?

I introduced a controlled Terraform configuration change by adding the temporary tag `DriftReviewTest = "controlled-difference"` to the existing AWS security group.

### 2. Was it true infrastructure drift or a Terraform configuration change?

It was a Terraform configuration change, not true infrastructure drift. I intentionally edited `main.tf`, while the deployed AWS resource had not been changed outside Terraform.

### 3. What Terraform plan evidence proves that a change is pending?

Terraform returned detailed exit code `2` and the plan showed a pending in-place update to the security group. This proved that the current configuration differed from the deployed state.

### 4. Was the action an update, deletion, replacement, or security-rule change?

The controlled action was an in-place update to the security group's tags. It was not a deletion or replacement. The review also identified an existing world-open SSH rule, but that security exposure was already present and was not introduced by my controlled tag change.

### 5. What did Claude recommend?

Claude recommended reviewing the controlled tag before taking action, avoiding automatic apply, reviewing the existing SSH exposure, and re-running `/tf-drift-review` after the human-reviewed resolution.

### 6. Why should you review the recommendation before taking action?

The recommendation must be reviewed because AI can misunderstand context or recommend an action with unintended infrastructure impact. Terraform evidence and human judgment should be checked before any real change is executed.

---

# Task 7 — Add a `PreToolUse` Hook to Block Unsafe Apply Attempts

## Goal

Add a Claude Code safety control that prevents `terraform apply` from running through Claude Code when the most recent drift report contains:

```text
Overall Status: FAIL
```

## Evidence

### Screenshot 14 — `PreToolUse` Safety Hook

Add a screenshot of `.claude/settings.json` showing the `PreToolUse` safety hook.

![Screenshot 14](screenshots/week-08-assignment-06-screenshot-14-pretooluse-safety-hook.png)

---

### Screenshot 15 — Blocked Apply Attempt

Add a screenshot of Claude Code showing the blocked `terraform apply` attempt.

![Screenshot 15](screenshots/week-08-assignment-06-screenshot-15-blocked-apply-attempt.png)

## Questions

### 1. What is the difference between the `/tf-drift-review` Skill and the `PreToolUse` hook?

The `/tf-drift-review` Skill performs an evidence-based infrastructure review and explains the findings. The `PreToolUse` hook is a deterministic enforcement control that intercepts commands before execution and can block an unsafe `terraform apply`.

### 2. Which component performs analysis?

The `/tf-drift-review` Skill together with Claude performs the analysis of the Terraform evidence.

### 3. Which component enforces the safety gate?

The `PreToolUse` hook enforces the safety gate by denying `terraform apply` when the latest drift report contains `Overall Status: FAIL`.

### 4. Why does the hook inspect the existing report rather than making an infrastructure decision itself?

The hook inspects the existing report because the report is the output of the evidence-gathering and analysis workflow. The hook should enforce a known decision condition rather than independently reasoning about the infrastructure.

### 5. Why is a deterministic guard useful for high-impact commands?

A deterministic guard is useful because high-impact commands need predictable enforcement. Unlike an AI judgment, the hook follows the same explicit rule every time and blocks the command when the configured failure condition is present.

---

# Task 8 — Resolve the Difference and Verify the Final State

## Goal

Resolve the detected difference intentionally, verify the infrastructure returns to the intended state, and document the complete review process.

## Evidence

### Screenshot 16 — Human-Reviewed Resolution

Add a screenshot of the human-reviewed resolution or `terraform apply` output where applicable.

![Screenshot 16](screenshots/week-08-assignment-06-screenshot-16-human-reviewed-resolution.png)

---

### Screenshot 17 — Final Healthy Review

Add a screenshot of the final `/tf-drift-review` showing `HEALTHY`.

![Screenshot 17](screenshots/week-08-assignment-06-screenshot-17-final-healthy-review.png)

---

### Screenshot 18 — Saved Reports

Add a screenshot of `ls -lah reports` showing both:

- `drift-detected-report.txt`
- `resolved-report.txt`

![Screenshot 18](screenshots/week-08-assignment-06-screenshot-18-saved-reports.png)

---

### Screenshot 19 — Drift Review Summary

Add a screenshot of `drift-review-summary.md` showing all required sections and your full name.

![Screenshot 19](screenshots/week-08-assignment-06-screenshot-19-drift-review-summary.png)

## Terraform Drift Review Summary

### 1. Change Introduced

Explain the controlled change you introduced.

State whether it was:

- True infrastructure drift, or
- A Terraform configuration change

I introduced a temporary Terraform tag, `DriftReviewTest = "controlled-difference"`, on the existing security group. The configuration change was intentionally created for the drift-review exercise and was never applied to AWS.

### 2. Evidence Collected

Describe the Terraform plan evidence and affected resource.

The workflow collected evidence with `terraform plan -detailed-exitcode`, which returned exit code `2` during the controlled test. The plan showed an in-place security-group tag update with no deletion or replacement. The policy check also detected the existing SSH rule open to `0.0.0.0/0`, and `drift-detected-report.txt` recorded `Overall Status: FAIL`.

### 3. Risk Assessment

Explain the risk identified by the Bash check and Claude Code.

The temporary tag was a low-risk controlled configuration change. The review also revealed that SSH port 22 was already open to `0.0.0.0/0`. That exposure was not introduced by the controlled test but still represented a security finding requiring human review.

### 4. Human-Approved Action

Explain the action you reviewed and executed manually.

After reviewing the evidence, I chose not to apply the temporary tag. I manually removed `DriftReviewTest = "controlled-difference"` from `main.tf`. No `terraform apply` or `terraform destroy` was used to resolve the controlled difference.

### 5. Verification

Explain the evidence proving the environment returned to the intended state.

I ran the drift review again after removing the temporary tag. Terraform returned detailed exit code `0`, the report showed no pending changes, and the final `/tf-drift-review` result was `HEALTHY`. The clean result was also saved as `resolved-report.txt`.

### 6. Safety Decision

Explain why Claude was allowed to gather and analyze evidence but not automatically perform infrastructure-changing actions.

Infrastructure-changing actions remained under human control. The `/tf-drift-review` Skill performed read-only analysis, and the `PreToolUse` hook successfully blocked a `terraform apply` attempt while the latest report contained `Overall Status: FAIL`.

### 7. Agentic Loop Mapping

Explain how your workflow followed:

```text
Gather --> Analyze --> Human Act --> Verify
```

Observe: Terraform and the Bash script collected current plan evidence. Analyze: Claude reviewed the reports and Terraform evidence. Recommend: Claude explained the findings and suggested human-reviewed actions. Human Decision: I chose not to apply the temporary tag. Act: I manually removed the controlled configuration change. Verify: I re-ran `/tf-drift-review` and confirmed a final `HEALTHY` result.

## Questions

### 1. What action did you execute to resolve the difference?

I resolved the difference by manually removing the temporary `DriftReviewTest = "controlled-difference"` tag from `main.tf`. I did not apply the temporary change to AWS.

### 2. Did you review `terraform plan` before taking action?

Yes. I reviewed the Terraform plan and the drift-review evidence before deciding how to resolve the controlled difference.

### 3. What evidence proves the environment is now aligned?

Terraform returned detailed exit code `0`, the report stated that there were no pending changes, `/tf-drift-review` returned `HEALTHY`, and `resolved-report.txt` captured the clean final state.

### 4. Why is a second drift review required after the fix?

A second drift review verifies that the chosen resolution actually restored alignment and did not introduce another unintended Terraform difference or policy finding.

### 5. What could go wrong if an AI agent automatically applied every detected Terraform change?

An AI agent could misinterpret a plan, apply an unsafe or destructive change, replace resources unnecessarily, expose services, or create an outage before a human has reviewed the impact.

### 6. In one sentence, explain the difference between asking an AI chatbot “Is my infrastructure okay?” and using this evidence-based Agentic AI workflow.

A chatbot question relies mainly on conversational reasoning, while this Agentic AI workflow first collects deterministic Terraform evidence, analyzes that evidence, applies a safety gate, keeps execution under human control, and verifies the final state.

---

# LinkedIn Post — Mandatory

## Goal

Publish a LinkedIn post in your own words describing:

- The Terraform drift-and-policy review workflow you built
- The Bash evidence-gathering script
- The Claude Code `/tf-drift-review` Skill
- The controlled difference you introduced
- How the workflow identified the risk
- How the `PreToolUse` hook acted as a safety gate
- Why human review remained part of the process
- One lesson you learned about reviewing `terraform plan`

Include a screenshot of the detected change and a screenshot of the final `HEALTHY` review in your post.

Suggested tags:

```text
#DMIByPravinMishra #Terraform #AgenticAI #ClaudeCode #DevOps
```

## LinkedIn Evidence

### LinkedIn Post URL

https://www.linkedin.com/feed/update/urn:li:activity:7517483705582579712/

### Published LinkedIn Post Screenshot — Mandatory

![Published LinkedIn Post](screenshots/week-08-assignment-06-linkedin-published-post.png)

---

# Required Assignment Files

Confirm that the following files are included in your GitHub repository:

- `CLAUDE.md`
- `AI Assignment/tf-drift-check.sh`
- `.claude/skills/tf-drift-review/SKILL.md`
- `.claude/settings.json` containing the safety hook
- `reports/drift-detected-report.txt`
- `reports/resolved-report.txt`
- `drift-review-summary.md`

---

# Submission Instructions

- Complete Tasks 1–8 in sequence.
- Include Screenshots 1–19 exactly as specified.
- Answer every question under Tasks 1–8 in your own words.
- Complete all seven sections of the Terraform Drift Review Summary.
- Include the GitHub repository/folder URL containing the assignment files.
- Include your full name in the required reports and screenshots.
- Include the LinkedIn post URL and a screenshot of the published LinkedIn post.
- Do not expose access keys, passwords, tokens, account IDs, private keys, Terraform secrets, or other sensitive information.
- Review all screenshots carefully and hide or redact sensitive details where necessary.

---

# Completion Checklist

- [x] Confirmed a clean Terraform baseline
- [x] Created the required assignment workspace
- [x] Created or updated `CLAUDE.md`
- [x] Added project context and safety rules
- [x] Created `tf-drift-check.sh`
- [x] Added my full name to the report
- [x] Validated the Bash script
- [x] Made the script executable
- [x] Used `terraform plan -detailed-exitcode`
- [x] Used Terraform plan JSON
- [x] Used `jq` to inspect destructive actions
- [x] Used `jq` to inspect unsafe ingress
- [x] Confirmed the baseline returns `HEALTHY`
- [x] Created `/tf-drift-review`
- [x] Restricted the Skill to appropriate tools
- [x] Confirmed the Skill remains read-only
- [x] Confirmed the Skill never runs `terraform apply`
- [x] Confirmed the Skill never runs `terraform destroy`
- [x] Introduced a controlled detectable difference
- [x] Correctly identified whether it was true drift or a configuration change
- [x] Saved `drift-detected-report.txt`
- [x] Added the `PreToolUse` safety hook
- [x] Verified the hook blocks `terraform apply` when the report is `FAIL`
- [x] Reviewed the Terraform evidence before resolving the change
- [x] Performed any infrastructure-changing action manually
- [x] Ran the drift review again after resolution
- [x] Confirmed the final status is `HEALTHY`
- [x] Saved `resolved-report.txt`
- [x] Completed `drift-review-summary.md`
- [x] Mapped the workflow to `Gather --> Analyze --> Human Act --> Verify`
- [x] Included all 19 numbered screenshots
- [x] Answered all required questions
- [x] Published the required LinkedIn post
- [x] Added the LinkedIn post URL and screenshot
- [x] Included the GitHub repository/folder URL
- [x] Confirmed that no sensitive information is exposed

---

*This submission is part of the DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*