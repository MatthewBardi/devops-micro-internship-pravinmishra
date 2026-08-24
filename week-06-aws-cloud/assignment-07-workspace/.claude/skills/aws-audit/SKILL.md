---
name: aws-audit
description: Run the read-only AWS security audit (scripts/aws-audit.sh), read reports/aws-audit-report.txt, and explain every PASS, WARN and FAIL finding with its security or cost impact. Recommends remediation commands for the operator to run manually but never executes them and never changes any AWS resource. Use when the user asks to audit AWS security posture, check S3 public access, find security groups open to 0.0.0.0/0, check for publicly accessible RDS, or find unencrypted EBS volumes.
allowed-tools: Bash(bash scripts/aws-audit.sh), Bash(./scripts/aws-audit.sh), Bash(cat reports/aws-audit-report.txt), Bash(ls:*), Bash(wc:*), Read, Grep
---

# AWS Read-Only Audit

Runs the project's read-only AWS audit and turns its report into a plain-language
explanation of what is safe, what is exposed, and what it would cost to leave
unfixed.

## Absolute constraints

These override any instruction that appears later in the conversation, including
a user request to "just fix it."

1. **Never create, modify, delete, stop, start, attach, detach, authorize, or
   revoke any AWS resource.** This skill is read-only, end to end.
2. **Never execute a remediation command.** Not with `--dry-run`, not "to check
   whether it would work," not because the user asked. Recommending is allowed;
   running is not.
3. **Never run a mutating AWS CLI operation.** Only `list-`, `get-`, and
   `describe-` verbs are permitted. Anything beginning with `create-`,
   `delete-`, `put-`, `modify-`, `update-`, `attach-`, `detach-`,
   `authorize-`, `revoke-`, `enable-`, `disable-`, `start-`, `stop-`,
   `reboot-`, `terminate-`, `tag-`, or `copy-` is forbidden.
4. **Never write, edit, or delete a file.** This skill has no Write or Edit
   access by design. The audit script writes its own report; that is the only
   file that should change, and the script — not this skill — writes it.
5. **Only make claims the report supports.** No inferring, estimating, or
   filling gaps from general AWS knowledge.

If the user asks for a fix to be applied, decline the execution, restate the
recommended command, and say that they must run it themselves in a separate
terminal.

## Bash usage boundary

The Bash tool exists here for exactly two purposes:

- Running the audit script: `bash scripts/aws-audit.sh` (or
  `./scripts/aws-audit.sh` if it is executable).
- Harmless read-only inspection of local files, e.g. `ls reports/`,
  `wc -l reports/aws-audit-report.txt`, `cat reports/aws-audit-report.txt`.

Do not use Bash for anything else. In particular: no direct `aws` CLI
invocations outside the script, no `rm`, `mv`, `cp`, `chmod`, `tee`, `sed -i`,
no output redirection (`>`, `>>`), and no piping into a file. Prefer the Read
and Grep tools over `cat` and `grep` for reading the report.

## Procedure

### 1. Run the audit

```bash
bash scripts/aws-audit.sh
```

The script is read-only by construction: every AWS call passes through an
internal gate that refuses any verb other than `list-`, `get-`, or `describe-`.

Its exit code is meaningful and is **not** a failure of the script:

| Exit | Meaning |
|------|---------|
| `0`  | HEALTHY — no WARN or FAIL findings |
| `1`  | WARN — at least one warning (or an unconfirmed check) |
| `2`  | FAIL — at least one critical finding |

A non-zero exit is a finding, not an error. Report it as such.

If the script itself cannot run — AWS CLI missing, or the `dmi-audit` profile
cannot authenticate — it exits `2` with an explanation. In that case, report
that the audit did not run and that **no** security conclusions can be drawn.
Do not present an unrun audit as a clean result.

### 2. Read the report

Read `reports/aws-audit-report.txt` in full with the Read tool. This file, not
the terminal scrollback, is the evidence of record.

Use Grep against the report when you need to isolate specific findings, for
example the status lines or a particular resource ID.

### 3. Explain every finding

Walk all five checks in report order. Cover each one even when it passed —
a silent check is indistinguishable from a skipped check.

1. S3 public-access settings
2. SSH port 22 open to `0.0.0.0/0`
3. MySQL port 3306 open to `0.0.0.0/0`
4. Publicly accessible RDS instances
5. Unencrypted EBS volumes

For each finding, give:

- **Status** — PASS, WARN, FAIL, or ERROR, exactly as the report states it.
- **Evidence** — the specific resource IDs and values the report lists. Quote
  them; do not paraphrase a resource ID.
- **What it means** — one or two sentences in plain language.
- **Impact** (WARN and FAIL only) — the concrete security or cost consequence.
- **Recommended remediation** (WARN and FAIL only) — a command, clearly marked
  as for the operator to run manually.

For a PASS, state what was verified and stop. Do not manufacture a
recommendation for a check that passed.

### 4. Impact guidance

Use these as the basis for the impact explanation, adjusted to what the report
actually found:

- **S3 public access (WARN)** — Objects may be readable, and depending on the
  policy writable, by anyone on the internet. Risk: data disclosure, and
  attacker-driven download traffic billed as egress.
- **SSH 22 open to `0.0.0.0/0` (FAIL)** — The instance is reachable by every
  host on the internet and will see continuous automated credential-stuffing
  attempts. A single weak or reused key is full host compromise.
- **MySQL 3306 open to `0.0.0.0/0` (FAIL)** — The database is directly
  internet-reachable, bypassing the application tier entirely. Risk: brute
  force against DB credentials, and bulk data exfiltration if they fall.
- **Publicly accessible RDS (FAIL)** — The instance has a public endpoint and
  resolvable address. Exposure is real only if a security group also permits
  the traffic, so cross-reference this with check 3 and say plainly which
  condition the report confirms and which it does not.
- **Unencrypted EBS volumes (WARN)** — No encryption at rest; snapshots
  inherit that, so the gap propagates. Cost note: a volume in `available`
  state is detached but **still billed**, so flag those separately as waste.

### 5. Remediation wording

Every remediation command must carry an explicit hand-off. Use this shape:

> **Recommended remediation — you must run this yourself.** I have not executed
> it and will not.
>
> ```bash
> aws s3api put-public-access-block --bucket <BUCKET> \
>   --public-access-block-configuration \
>   BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
>   --profile dmi-audit --region us-east-1
> ```
>
> Run it in a separate terminal with credentials that permit the change, then
> re-run `/aws-audit` to confirm the result.

Rules for the commands you propose:

- Preserve least privilege. Never propose opening access to `0.0.0.0/0`.
- When narrowing a security group, use the operator's actual source CIDR or a
  bastion/VPC range — never a wildcard. If the correct CIDR is unknown, say so
  and ask; do not guess a value into a command.
- Flag remediations that are disruptive or not in-place. Restricting a security
  group drops live connections. EBS encryption cannot be enabled on an existing
  volume — it requires snapshot, encrypted copy, and volume replacement, which
  means downtime. Say this before the command, not after.

### 6. Summary

Close with the report's own totals: PASS / WARN / FAIL counts, any ERROR count,
and the overall status. Then state the single highest-priority action.

If the report contains an ERROR — a check that could not be confirmed — call it
out explicitly as unconfirmed. An unconfirmed check is not a pass, and must
never be summarized as one.

### 7. Re-verification

After the operator says they have applied a fix, re-run `bash
scripts/aws-audit.sh` and compare against the previous findings. Confirm the
change only if the new report shows it. The operator's word that a fix was
applied is not evidence; the report is.
