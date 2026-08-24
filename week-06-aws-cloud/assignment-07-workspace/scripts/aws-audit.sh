#!/usr/bin/env bash
#
# aws-audit.sh — read-only AWS security audit
#
# Author : Matthew Bardi
# Course : DevOps Micro Internship — Week 06 / Assignment 07
#
# THIS SCRIPT IS STRICTLY READ-ONLY.
# It issues only list-, get- and describe- AWS CLI operations. It never
# creates, modifies, deletes, attaches, detaches, authorizes or revokes any
# AWS resource, and it never performs remediation. Remediation is reported
# as a recommendation only and must be run manually by the operator.
#
# Every AWS CLI call goes through aws_ro(), which refuses to execute any
# operation whose verb is not list-, get- or describe-.
#
# Usage: bash scripts/aws-audit.sh
# Exit : 0 = HEALTHY   1 = WARN   2 = FAIL
#

# No `-e`: an individual AWS call may legitimately fail (missing permission,
# service not in use) and the audit must continue and report that honestly.
set -uo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

FULL_NAME="Matthew Bardi"
AUDIT_PROFILE="dmi-audit"
AUDIT_REGION="us-east-1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPORT_DIR="${PROJECT_ROOT}/reports"
REPORT_FILE="${REPORT_DIR}/aws-audit-report.txt"

# The five checks, in report order.
CHECKS=(
  "S3 public-access settings"
  "SSH port 22 open to 0.0.0.0/0"
  "MySQL port 3306 open to 0.0.0.0/0"
  "Publicly accessible RDS instances"
  "Unencrypted EBS volumes"
)

# Parallel arrays holding the outcome of each check.
STATUSES=()
DETAILS=()

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
ERROR_COUNT=0

# ---------------------------------------------------------------------------
# Output helpers — everything printed also lands in the report file.
# ---------------------------------------------------------------------------

out() {
  printf '%s\n' "$*" | tee -a "$REPORT_FILE"
}

rule() {
  out "-----------------------------------------------------------------------"
}

# record <index> <status> <detail>
record() {
  local idx="$1" status="$2" detail="$3"
  STATUSES[$idx]="$status"
  DETAILS[$idx]="$detail"
  case "$status" in
    PASS)  PASS_COUNT=$((PASS_COUNT + 1)) ;;
    WARN)  WARN_COUNT=$((WARN_COUNT + 1)) ;;
    FAIL)  FAIL_COUNT=$((FAIL_COUNT + 1)) ;;
    ERROR) ERROR_COUNT=$((ERROR_COUNT + 1)) ;;
  esac
}

# ---------------------------------------------------------------------------
# Read-only AWS CLI gate
# ---------------------------------------------------------------------------

# aws_ro_in <region> <service> <operation> [args...]
aws_ro_in() {
  local region="$1" service="$2" operation="$3"
  shift 3

  case "$operation" in
    list-*|get-*|describe-*) ;;
    *)
      printf 'SAFETY BLOCK: refused non-read-only operation: aws %s %s\n' \
        "$service" "$operation" >&2
      return 90
      ;;
  esac

  aws "$service" "$operation" \
    --profile "$AUDIT_PROFILE" \
    --region "$region" \
    "$@"
}

# aws_ro <service> <operation> [args...] — uses the configured audit region.
aws_ro() {
  aws_ro_in "$AUDIT_REGION" "$@"
}

# ---------------------------------------------------------------------------
# Check 1 — S3 public-access settings                              PASS / WARN
# ---------------------------------------------------------------------------
check_s3_public_access() {
  local idx=0
  out "[1/5] ${CHECKS[0]}"

  local buckets
  buckets="$(aws_ro s3api list-buckets \
    --query 'Buckets[].Name' \
    --output text)" || {
      out "      Could not list S3 buckets — result NOT confirmed."
      record "$idx" "ERROR" "s3api list-buckets failed"
      return
    }

  if [[ -z "${buckets// /}" ]]; then
    out "      No S3 buckets found in this account."
    record "$idx" "PASS" "no buckets present"
    return
  fi

  local exposed=""
  local bucket loc bregion flags policy_public

  for bucket in $buckets; do
    # Buckets are global but their control-plane calls are region-bound,
    # so resolve each bucket's own region first.
    loc="$(aws_ro s3api get-bucket-location \
      --bucket "$bucket" \
      --query 'LocationConstraint' \
      --output text 2>/dev/null)"
    bregion="$loc"
    if [[ -z "$bregion" || "$bregion" == "None" || "$bregion" == "null" ]]; then
      bregion="us-east-1"
    fi

    # Block Public Access. An error here means no BPA config exists at all,
    # which is itself the finding — it must not be swallowed as "clean".
    flags="$(aws_ro_in "$bregion" s3api get-public-access-block \
      --bucket "$bucket" \
      --query 'PublicAccessBlockConfiguration.[BlockPublicAcls,IgnorePublicAcls,BlockPublicPolicy,RestrictPublicBuckets]' \
      --output text 2>/dev/null)"

    if [[ -z "$flags" ]]; then
      out "      ${bucket}: no Block Public Access configuration"
      exposed="${exposed}${bucket}(no-BPA) "
    elif [[ "$flags" == *"False"* || "$flags" == *"false"* ]]; then
      out "      ${bucket}: Block Public Access incomplete [${flags}]"
      exposed="${exposed}${bucket}(partial-BPA) "
    fi

    # AWS's own verdict on the bucket policy.
    policy_public="$(aws_ro_in "$bregion" s3api get-bucket-policy-status \
      --bucket "$bucket" \
      --query 'PolicyStatus.IsPublic' \
      --output text 2>/dev/null)"

    if [[ "$policy_public" == "True" || "$policy_public" == "true" ]]; then
      out "      ${bucket}: bucket policy is PUBLIC"
      exposed="${exposed}${bucket}(public-policy) "
    fi
  done

  if [[ -n "$exposed" ]]; then
    record "$idx" "WARN" "public-access exposure: ${exposed% }"
  else
    out "      All buckets enforce Block Public Access; no public policies."
    record "$idx" "PASS" "all buckets protected"
  fi
}

# ---------------------------------------------------------------------------
# Check 2 — SSH port 22 open to 0.0.0.0/0                          PASS / FAIL
# ---------------------------------------------------------------------------
# The JMESPath below deliberately does not rely on an exact from-port match.
# It also catches port-range rules (0-65535) and IpProtocol "-1" (all
# traffic), both of which expose port 22 while having no FromPort of 22.
# Backtick JSON literals are used so the whole query can live inside single
# quotes and bash performs no substitution on it.
# ---------------------------------------------------------------------------
check_ssh_open() {
  local idx=1
  out "[2/5] ${CHECKS[1]}"

  local hits
  hits="$(aws_ro ec2 describe-security-groups \
    --query 'SecurityGroups[?IpPermissions[?(IpProtocol==`"-1"` || (FromPort<=`22` && ToPort>=`22`)) && IpRanges[?CidrIp==`"0.0.0.0/0"`]]].[GroupId,GroupName,VpcId]' \
    --output text)" || {
      out "      Could not describe security groups — result NOT confirmed."
      record "$idx" "ERROR" "ec2 describe-security-groups failed"
      return
    }

  if [[ -z "${hits//[[:space:]]/}" ]]; then
    out "      No security group exposes port 22 to 0.0.0.0/0."
    record "$idx" "PASS" "no world-open SSH"
    return
  fi

  out "      Security groups exposing SSH to the internet:"
  out "$hits"
  record "$idx" "FAIL" "SSH 22 open to 0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# Check 3 — MySQL port 3306 open to 0.0.0.0/0                      PASS / FAIL
# ---------------------------------------------------------------------------
check_mysql_open() {
  local idx=2
  out "[3/5] ${CHECKS[2]}"

  local hits
  hits="$(aws_ro ec2 describe-security-groups \
    --query 'SecurityGroups[?IpPermissions[?(IpProtocol==`"-1"` || (FromPort<=`3306` && ToPort>=`3306`)) && IpRanges[?CidrIp==`"0.0.0.0/0"`]]].[GroupId,GroupName,VpcId]' \
    --output text)" || {
      out "      Could not describe security groups — result NOT confirmed."
      record "$idx" "ERROR" "ec2 describe-security-groups failed"
      return
    }

  if [[ -z "${hits//[[:space:]]/}" ]]; then
    out "      No security group exposes port 3306 to 0.0.0.0/0."
    record "$idx" "PASS" "no world-open MySQL"
    return
  fi

  out "      Security groups exposing MySQL to the internet:"
  out "$hits"
  record "$idx" "FAIL" "MySQL 3306 open to 0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# Check 4 — Publicly accessible RDS instances                      PASS / FAIL
# ---------------------------------------------------------------------------
check_rds_public() {
  local idx=3
  out "[4/5] ${CHECKS[3]}"

  local instances clusters call_failed=0

  instances="$(aws_ro rds describe-db-instances \
    --query 'DBInstances[?PubliclyAccessible==`true`].[DBInstanceIdentifier,Engine,Endpoint.Address]' \
    --output text)" || call_failed=1

  # describe-db-instances does not cover Aurora/cluster engines.
  clusters="$(aws_ro rds describe-db-clusters \
    --query 'DBClusters[?PubliclyAccessible==`true`].[DBClusterIdentifier,Engine]' \
    --output text 2>/dev/null)" || clusters=""

  if [[ "$call_failed" -eq 1 ]]; then
    out "      Could not describe RDS instances — result NOT confirmed."
    record "$idx" "ERROR" "rds describe-db-instances failed"
    return
  fi

  local hits="${instances}
${clusters}"

  if [[ -z "${hits//[[:space:]]/}" ]]; then
    out "      No RDS instance or cluster is publicly accessible."
    record "$idx" "PASS" "no public RDS"
    return
  fi

  out "      Publicly accessible RDS resources:"
  [[ -n "${instances//[[:space:]]/}" ]] && out "$instances"
  [[ -n "${clusters//[[:space:]]/}"  ]] && out "$clusters"
  record "$idx" "FAIL" "RDS publicly accessible"
}

# ---------------------------------------------------------------------------
# Check 5 — Unencrypted EBS volumes                                PASS / WARN
# ---------------------------------------------------------------------------
check_ebs_encryption() {
  local idx=4
  out "[5/5] ${CHECKS[4]}"

  # Informational only: the region default for newly created volumes.
  local default_enc
  default_enc="$(aws_ro ec2 get-ebs-encryption-by-default \
    --query 'EbsEncryptionByDefault' \
    --output text 2>/dev/null)"
  out "      EBS encryption-by-default for ${AUDIT_REGION}: ${default_enc:-unknown}"

  local volumes
  volumes="$(aws_ro ec2 describe-volumes \
    --filters "Name=encrypted,Values=false" \
    --query 'Volumes[].[VolumeId,Size,VolumeType,State,AvailabilityZone]' \
    --output text)" || {
      out "      Could not describe EBS volumes — result NOT confirmed."
      record "$idx" "ERROR" "ec2 describe-volumes failed"
      return
    }

  if [[ -z "${volumes//[[:space:]]/}" ]]; then
    out "      All EBS volumes are encrypted at rest."
    record "$idx" "PASS" "no unencrypted volumes"
    return
  fi

  out "      Unencrypted EBS volumes (VolumeId Size Type State AZ):"
  out "$volumes"
  record "$idx" "WARN" "unencrypted EBS volumes present"
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
print_summary() {
  local overall exit_code

  if [[ "$FAIL_COUNT" -gt 0 ]]; then
    overall="FAIL"; exit_code=2
  elif [[ "$WARN_COUNT" -gt 0 || "$ERROR_COUNT" -gt 0 ]]; then
    overall="WARN"; exit_code=1
  else
    overall="HEALTHY"; exit_code=0
  fi

  out ""
  rule
  out "AUDIT SUMMARY"
  rule
  out "Full Name : ${FULL_NAME}"
  out "Profile   : ${AUDIT_PROFILE}"
  out "Region    : ${AUDIT_REGION}"
  out ""

  local i
  for i in "${!CHECKS[@]}"; do
    printf '%-6s %s\n' "${STATUSES[$i]:-ERROR}" "${CHECKS[$i]}" | tee -a "$REPORT_FILE"
    out "       -> ${DETAILS[$i]:-not evaluated}"
  done

  out ""
  out "PASS  : ${PASS_COUNT}"
  out "WARN  : ${WARN_COUNT}"
  out "FAIL  : ${FAIL_COUNT}"
  if [[ "$ERROR_COUNT" -gt 0 ]]; then
    out "ERROR : ${ERROR_COUNT}  (checks that could not be confirmed)"
  fi
  out ""
  out "OVERALL STATUS: ${overall}"
  rule
  out "Report written to: ${REPORT_FILE}"
  out "This audit made no changes to any AWS resource."
  out "Any remediation must be reviewed and run manually by the operator."

  return "$exit_code"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  mkdir -p "$REPORT_DIR"
  : > "$REPORT_FILE"

  rule
  out "AWS READ-ONLY SECURITY AUDIT"
  rule
  out "Full Name : ${FULL_NAME}"
  out "Profile   : ${AUDIT_PROFILE}"
  out "Region    : ${AUDIT_REGION}"
  out "Mode      : READ-ONLY (list-/get-/describe- only, no remediation)"
  rule
  out ""

  if ! command -v aws >/dev/null 2>&1; then
    out "ERROR: AWS CLI not found on PATH. Audit aborted."
    exit 2
  fi

  local account
  account="$(aws_ro sts get-caller-identity \
    --query 'Account' \
    --output text)" || {
      out "ERROR: cannot authenticate with profile '${AUDIT_PROFILE}'. Audit aborted."
      exit 2
    }
  out ""

  check_s3_public_access
  out ""
  check_ssh_open
  out ""
  check_mysql_open
  out ""
  check_rds_public
  out ""
  check_ebs_encryption

  print_summary
  exit $?
}

main "$@"
