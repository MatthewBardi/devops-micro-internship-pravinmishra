#!/usr/bin/env bash

# Terraform Drift and Policy Review
# Student: Matthew Bardi

set -u

STUDENT_NAME="Matthew Bardi"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(cd "${SCRIPT_DIR}/../terraform-aws-vm" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/reports"

PLAN_FILE="${REPORT_DIR}/tfplan"
PLAN_JSON="${REPORT_DIR}/tfplan.json"
PLAN_TEXT="${REPORT_DIR}/terraform-plan.txt"

REPORT_NAME="${1:-baseline-report.txt}"
REPORT_FILE="${REPORT_DIR}/${REPORT_NAME}"
LATEST_REPORT="${REPORT_DIR}/latest-report.txt"

checks=(
  "check_plan_status"
  "check_destructive_actions"
  "check_open_ingress"
)

PLAN_EXIT=1
OVERALL_STATUS="HEALTHY"

mkdir -p "${REPORT_DIR}"

log() {
  echo "$1" | tee -a "${REPORT_FILE}"
}

set_warn() {
  if [[ "${OVERALL_STATUS}" == "HEALTHY" ]]; then
    OVERALL_STATUS="WARN"
  fi
}

set_fail() {
  OVERALL_STATUS="FAIL"
}

check_plan_status() {
  case "${PLAN_EXIT}" in
    0)
      log "[PASS] Terraform plan: no pending changes."
      ;;
    2)
      log "[WARN] Terraform plan: pending changes detected."
      set_warn
      ;;
    *)
      log "[FAIL] Terraform plan could not be generated successfully."
      set_fail
      ;;
  esac
}

check_destructive_actions() {
  if [[ "${PLAN_EXIT}" -eq 0 ]]; then
    log "[PASS] Destructive actions: no pending plan changes to inspect."
    return
  fi

  if [[ ! -f "${PLAN_JSON}" ]]; then
    log "[FAIL] Destructive actions: Terraform plan JSON is unavailable."
    set_fail
    return
  fi

  local delete_count

  delete_count="$(
    jq '
      [
        .resource_changes[]?
        | select(
            any(.change.actions[]?; . == "delete")
          )
      ]
      | length
    ' "${PLAN_JSON}"
  )"

  if [[ "${delete_count}" -gt 0 ]]; then
    log "[FAIL] Destructive actions: ${delete_count} resource change(s) contain delete actions."
    log "       A replacement also contains a delete action and is treated as destructive."
    set_fail
  else
    log "[PASS] Destructive actions: no delete or replacement actions detected."
  fi
}

check_open_ingress() {
  if [[ "${PLAN_EXIT}" -eq 0 ]]; then
    log "[PASS] Open ingress: no pending plan changes to inspect."
    return
  fi

  if [[ ! -f "${PLAN_JSON}" ]]; then
    log "[FAIL] Open ingress: Terraform plan JSON is unavailable."
    set_fail
    return
  fi

  local unsafe_count

  unsafe_count="$(
    jq '
      [
        (
          .resource_changes[]?
          | select(.type == "aws_security_group")
          | .change.after.ingress[]?
          | select(
              ((.cidr_blocks // []) | index("0.0.0.0/0")) != null
            )
          | select(
              (.from_port // -1) != 80
              and (.from_port // -1) != 443
            )
        ),
        (
          .resource_changes[]?
          | select(.type == "aws_vpc_security_group_ingress_rule")
          | .change.after
          | select(.cidr_ipv4 == "0.0.0.0/0")
          | select(
              (.from_port // -1) != 80
              and (.from_port // -1) != 443
            )
        )
      ]
      | length
    ' "${PLAN_JSON}"
  )"

  if [[ "${unsafe_count}" -gt 0 ]]; then
    log "[FAIL] Open ingress: ${unsafe_count} unsafe rule(s) expose non-HTTP/HTTPS traffic to 0.0.0.0/0."
    set_fail
  else
    log "[PASS] Open ingress: no unsafe world-open ingress detected."
  fi
}

run_terraform_plan() {
  rm -f "${PLAN_FILE}" "${PLAN_JSON}" "${PLAN_TEXT}"

  pushd "${TERRAFORM_DIR}" >/dev/null || exit 2

  terraform plan \
    -detailed-exitcode \
    -out="${PLAN_FILE}" \
    -no-color \
    >"${PLAN_TEXT}" 2>&1

  PLAN_EXIT=$?

  if [[ "${PLAN_EXIT}" -eq 2 ]]; then
    terraform show -json "${PLAN_FILE}" >"${PLAN_JSON}"
  fi

  popd >/dev/null || exit 2
}

write_header() {
  : >"${REPORT_FILE}"

  log "Terraform Drift and Policy Review"
  log "Full Name: ${STUDENT_NAME}"
  log "Terraform Project: ${TERRAFORM_DIR}"
  log "Report: ${REPORT_FILE}"
  log "----------------------------------------"
}

write_summary() {
  log "----------------------------------------"
  log "Terraform detailed exit code: ${PLAN_EXIT}"
  log "Overall Status: ${OVERALL_STATUS}"

  cp "${REPORT_FILE}" "${LATEST_REPORT}"

  case "${OVERALL_STATUS}" in
    HEALTHY)
      return 0
      ;;
    WARN)
      return 1
      ;;
    FAIL)
      return 2
      ;;
  esac
}

main() {
  write_header
  run_terraform_plan

  for check in "${checks[@]}"; do
    "${check}"
  done

  write_summary
}

main "$@"
exit $?