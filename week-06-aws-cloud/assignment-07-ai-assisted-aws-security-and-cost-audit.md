# Assignment 7 — AI-Assisted AWS Security and Cost Audit

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will build a read-only Bash script that audits the AWS resources you deployed earlier this week — your S3 static site, EC2 instance(s), security groups, RDS database, and EBS volumes — for common security and cost misconfigurations.

You will then connect that script to Claude Code as a reusable `/aws-audit` skill that explains what it found and recommends a fix, without ever making the fix itself.

Finally, you will find a real misconfiguration in your own account, apply the fix yourself, and prove it worked with a second audit run.

---

# Task 1 — Confirm Your AWS Resources and Set Up Your Workspace

## Goal

Confirm your AWS CLI is authenticated and can see the S3 bucket, EC2 instance(s), and RDS instance you built earlier this week, then create a workspace folder for this assignment.

### Evidence

#### Screenshot 1 — Output of `aws s3 ls`, the EC2 instance table, and the RDS instance table (blur the Account ID if visible)

![Screenshot 1 - AWS resources](screenshots/week-06-assignment-07-screenshot-01-aws-resources.png)

---

#### Screenshot 2 — Output of `pwd` and `find . -maxdepth 4 -type d | sort`

![Screenshot 2 - Workspace](screenshots/week-06-assignment-07-screenshot-02-workspace.png)

---

### Notes You Must Write (Very Important)

**1. Which resources from this week's earlier assignments did you see in the listings?**

The listings showed my S3 portfolio bucket, EC2 resources from earlier Week 6 assignments including the mini-finance, EpicBook, and three-tier application instances, and the ha-mysql primary plus br-mysql-read-replica RDS instances.

**2. Why must you confirm your resources exist before writing an audit script against them?**

Confirming the resources first proves that I am auditing the correct AWS account and Region and that the expected resources actually exist. Otherwise, a missing resource or permission problem could be incorrectly interpreted as a secure PASS result.

---

# Task 2 — Define Safety Rules in CLAUDE.md

## Goal

Create a `CLAUDE.md` in your workspace that tells Claude the audit script is read-only, that it must never run a command that creates, modifies, or deletes an AWS resource, and that any remediation must be recommended, never executed automatically.

### Evidence

#### Screenshot 3 — `CLAUDE.md` open in VS Code showing all four sections

![Screenshot 3 - CLAUDE.md](screenshots/week-06-assignment-07-screenshot-03-claude-md.png)

---

### Notes You Must Write (Very Important)

**1. Why should Claude never be given permission to run `revoke-security-group-ingress` itself, even if the fix is obviously correct?**

Claude should never run revoke-security-group-ingress itself because it changes live network access and could interrupt legitimate connectivity. The AI should identify the risk and recommend the change, while a human reviews the scope and executes it manually.

**2. Which rule prevents Claude from claiming a finding that the report does not support?**

The Evidence Rules prevent unsupported findings by requiring every claim to be backed by the audit script or AWS CLI evidence and by explicitly prohibiting invented or assumed findings.

---

# Task 3 — Plan the Audit with Claude Code

## Goal

Ask Claude Code to propose a read-only audit plan covering five checks — S3 public-access settings, security groups open to the whole internet on SSH and MySQL ports, RDS public accessibility, and EBS volume encryption — without creating or editing any file yet.

### Evidence

#### Screenshot 4 — Claude Code showing the five-check plan

![Screenshot 4 - Read-only audit plan](screenshots/week-06-assignment-07-screenshot-04-audit-plan.png)

---

### Notes You Must Write (Very Important)

**1. Which part of this task represents the Gather phase?**

The Gather phase is the collection of the current AWS configuration using read-only list-, get-, and describe- commands before any remediation is considered.

**2. Did every proposed command start with `describe-`, `get-`, or `list-`? Why does that matter?**

Yes. The proposed AWS operations used list-, get-, or describe- actions. That matters because these operations gather configuration evidence without intentionally modifying AWS resources.

---

# Task 4 — Build the AWS Audit Script

## Goal

Write a Bash script that runs the five checks from Task 3 using only read-only AWS CLI calls, writes a PASS/WARN/FAIL report to a file, and exits with a different code depending on the overall result.

Make it executable and confirm it has no syntax errors.

### Evidence

#### Screenshot 5 — Top section of `aws-audit.sh` showing the variables and the checks array

![Screenshot 5 - Audit script variables and checks](screenshots/week-06-assignment-07-screenshot-05-script-top.png)

---

#### Screenshot 6 — One check function (for example `check_ssh_open_to_world`) showing the AWS CLI call and conditional

![Screenshot 6 - SSH audit function](screenshots/week-06-assignment-07-screenshot-06-ssh-check-function.png)

---

#### Screenshot 7 — Output of `bash -n scripts/aws-audit.sh` and `ls -l scripts/aws-audit.sh`

![Screenshot 7 - Script validation](screenshots/week-06-assignment-07-screenshot-07-script-validation.png)

---

### Notes You Must Write (Very Important)

**1. What is stored in the checks array, and how does the loop use it?**

The checks array stores the names of the five audit checks in report order. The script uses the check indexes with the parallel status and detail data so the results can be recorded and printed consistently in the final summary.

**2. Why does every AWS CLI call in this script use `--query` and `--output text` instead of parsing raw JSON?**

Using --query and --output text reduces each AWS CLI response to only the fields the Bash logic needs. This makes comparisons predictable and avoids having to parse large raw JSON responses inside the script.

**3. Why does the script use different exit codes for HEALTHY, WARN, and FAIL?**

Different exit codes allow a person, CI pipeline, or other automation to distinguish a healthy audit from a warning or a failure without parsing the entire report. Exit 0 means HEALTHY, 1 means WARN, and 2 means FAIL.

---

# Task 5 — Run the Baseline Audit

## Goal

Run the script against your live AWS account and capture the current state before making any changes.

### Evidence

#### Screenshot 8 — Output of `./scripts/aws-audit.sh` showing your Full Name and all five checks

![Screenshot 8 - Baseline audit](screenshots/week-06-assignment-07-screenshot-08-baseline-audit.png)

---

#### Screenshot 9 — Output showing the captured exit code and final summary

![Screenshot 9 - Baseline summary](screenshots/week-06-assignment-07-screenshot-09-baseline-summary.png)

---

### Notes You Must Write (Very Important)

**1. What is the overall status of your baseline audit?**

The baseline audit overall status was WARN.

**2. Did any check return FAIL or WARN? If so, which one, and what evidence did it show?**

Two checks returned WARN. The S3 check showed incomplete Block Public Access settings and a public bucket policy on the portfolio bucket. The EBS check showed that encryption by default was disabled and listed existing unencrypted EBS volumes. SSH, MySQL, and public RDS checks passed.

**3. If every check passed, what does that tell you about the security posture of your account so far?**

Not every baseline check passed. If all five had passed, it would mean that these specific controls did not identify a problem at that time, but it would not prove that the entire AWS account was secure.

---

# Task 6 — Build and Run the /aws-audit Skill

## Goal

Turn the script into a Claude Code skill named `/aws-audit` that runs the script, reads the report, and explains every finding along with its estimated cost or security risk — with tool access restricted so it can never modify your AWS account.

### Evidence

#### Screenshot 10 — `SKILL.md` showing the frontmatter, tool restrictions, and safety rules

![Screenshot 10 - aws-audit skill](screenshots/week-06-assignment-07-screenshot-10-skill-md.png)

---

#### Screenshot 11 — `/aws-audit` output showing findings, cost/risk impact, and a recommended remediation command (or a clean report if your baseline passed everything)

![Screenshot 11 - Claude aws-audit output](screenshots/week-06-assignment-07-screenshot-11-aws-audit-skill.png)

---

### Notes You Must Write (Very Important)

**1. Why does this skill have Bash, Read, and Grep, but not Write?**

The skill has Bash, Read, and Grep so it can run the read-only audit, read the generated report, and search evidence. It has no Write or Edit permission so it cannot change the audit files or use file editing as part of remediation.

**2. What part is performed by Bash, and what part is performed by Claude?**

Bash performs the deterministic evidence collection by running aws-audit.sh. Claude reads and interprets the report, explains the security or cost impact, and recommends remediation without executing it.

**3. Why is estimating cost/risk impact something the AI adds on top of a plain PASS/FAIL script?**

The script produces deterministic PASS, WARN, and FAIL results, while AI can add context such as likely security exposure, potential cost impact, priority, and an explanation of why a finding matters.

---

# Task 7 — Fix a Real Finding and Re-Verify

## Goal

Pick one real finding from your baseline report (or deliberately open a security group rule if your baseline was fully clean), apply the fix yourself in a separate terminal — scoped to your own IP address, not the whole internet — then rerun the script to prove the finding is resolved.

### Evidence

#### Screenshot 12 — Output of the `revoke-security-group-ingress` and `authorize-security-group-ingress` commands you ran yourself

![Screenshot 12 - Manual SSH remediation](screenshots/week-06-assignment-07-screenshot-12-ssh-remediation.png)

---

#### Screenshot 13 — Rerun of `./scripts/aws-audit.sh` showing the finding is now PASS

![Screenshot 13 - SSH fix verified](screenshots/week-06-assignment-07-screenshot-13-ssh-fix-verified.png)

---

### Notes You Must Write (Very Important)

**1. Which exact finding did you fix, and what command did you run?**

I fixed the SSH finding showing port 22 open to 0.0.0.0/0 on security group sg-0f5ed1abae52ba88d. I manually ran revoke-security-group-ingress to remove 0.0.0.0/0 and authorize-security-group-ingress to allow port 22 only from 102.88.167.117/32.

**2. Why did you scope the new rule to your own IP address instead of leaving it open to `0.0.0.0/0`?**

Using my own /32 public IP limits SSH access to one source address instead of exposing the SSH service to every address on the internet. This substantially reduces the attack surface.

**3. Did Claude execute the remediation command, or did you? Why does that matter?**

I executed the remediation myself in AWS CloudShell. Claude did not execute it. This matters because the workflow keeps live AWS changes under explicit human review and approval.

**4. Which phase of the Agentic Loop does the Bash script represent? Which phase does Claude's explanation represent? Which phase is you running the fix?**

The Bash audit represents the Gather phase of the Agentic Loop, Claude explaining the findings represents the Reason or Analyze phase, and me manually running the remediation represents the Act phase. Rerunning the audit afterward represents Verify.

---

# LinkedIn Post (Required)

## Goal

Create a LinkedIn post including:

- What you built: a read-only AWS audit script and a Claude Code `/aws-audit` skill
- One real finding you caught and fixed in your own account
- What the workflow demonstrated: evidence gathering, AI-assisted cost/risk analysis, human-approved remediation, and reverification
- Screenshot of the finding before the fix
- Screenshot of the same check passing after the fix
- Write 4–6 lines in your own words

Suggested tags:

`#DMIByPravinMishra #AWS #AgenticAI #ClaudeCode #DevOps`

### Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

`https://www.linkedin.com/feed/update/urn:li:ugcPost:7497487646697508864/`

---

#### Screenshot of Published LinkedIn Post

![Published LinkedIn post](screenshots/week-06-assignment-07-linkedin-post.png)

---

# Submission Instructions

Complete all tasks in sequence.

Your submission must include:

- All 13 required task screenshots
- Answers to every **Notes You Must Write** question
- `CLAUDE.md`
- `scripts/aws-audit.sh`
- `.claude/skills/aws-audit/SKILL.md`
- `reports/aws-audit-report.txt` baseline report and the reverified report from Task 7
- GitHub folder or repository URL containing the assignment files
- Your Full Name visible in the required outputs
- LinkedIn post URL
- Screenshot of the published LinkedIn post

Submit only a Google Doc link.

Add the GitHub URL inside the Google Doc.

Follow the Assignment Submission Guidelines.

---

# Completion Checklist

- [x] Task 1: AWS resources confirmed and workspace created (Screenshots 1–2)
- [x] Task 2: `CLAUDE.md` created with project context and safety rules (Screenshot 3)
- [x] Task 3: Claude produced a read-only five-check audit plan before any script existed (Screenshot 4)
- [x] Task 4: `aws-audit.sh` built, executable, and passes `bash -n` (Screenshots 5–7)
- [x] Task 5: Baseline audit captured and saved with Full Name visible (Screenshots 8–9)
- [x] Task 6: `/aws-audit` skill loads and runs successfully with no Write permission (Screenshots 10–11)
- [x] Task 7: A real finding was fixed by you and reverified as PASS (Screenshots 12–13)
- [x] Skill never executed a remediation command
- [x] New security group rule is scoped to your own IP, not `0.0.0.0/0`
- [x] All 13 required task screenshots are included
- [x] All "Notes You Must Write" questions are answered in your own words
- [x] No AWS credentials or unblurred account IDs exposed
- [x] LinkedIn post published and URL submitted
- [x] GitHub URL included in the Google Doc
- [x] Google Doc is accessible
- [x] Link tested in incognito mode

---

# Final Submission

Submit only your Google Doc link.

### Question

Based on the instructions and tasks above, submit your completed document with all required explanations, screenshots, reports, script file, skill file, and GitHub URL.

`https://docs.google.com/document/d/1uS3ZHfLhmI-H7CaxKVqG1uF3AoJj9E8vXB29r9tfvws/edit?usp=sharing`

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*