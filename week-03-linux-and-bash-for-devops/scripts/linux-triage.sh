#!/bin/bash

FULL_NAME="Matthew Bardi"
REPORT_FILE="${1:-reports/latest-report.txt}"

DISK_WARN=80
DISK_FAIL=90
MEMORY_WARN=80
MEMORY_FAIL=90

checks=(
  check_nginx
  check_port_80
  check_http
  check_disk
  check_memory
)

healthy_count=0
warn_count=0
fail_count=0
exit_code=0

mkdir -p "$(dirname "$REPORT_FILE")"
: > "$REPORT_FILE"

record_result() {
  local status="$1"
  local check_name="$2"
  local evidence="$3"

  printf "[%s] %s — %s\n" "$status" "$check_name" "$evidence" |
    tee -a "$REPORT_FILE"

  case "$status" in
    HEALTHY)
      healthy_count=$((healthy_count + 1))
      ;;
    WARN)
      warn_count=$((warn_count + 1))
      ;;
    FAIL)
      fail_count=$((fail_count + 1))
      ;;
  esac
}
# Script owner: Matthew Bardi
check_nginx() {
  local nginx_status
  nginx_status="$(systemctl is-active nginx 2>/dev/null || true)"

  if [ "$nginx_status" = "active" ]; then
    record_result "HEALTHY" "Nginx service" "Service is active"
  else
    record_result "FAIL" "Nginx service" "Service status: ${nginx_status:-unknown}"
  fi
}

check_port_80() {
  local port_evidence
  port_evidence="$(ss -ltn 2>/dev/null | awk '$4 ~ /:80$/ {print; exit}')"

  if [ -n "$port_evidence" ]; then
    record_result "HEALTHY" "Port 80" "HTTP port is listening"
  else
    record_result "FAIL" "Port 80" "No listener detected on port 80"
  fi
}

check_http() {
  local http_code
  http_code="$(curl -sS -o /dev/null -w '%{http_code}' \
    --max-time 5 http://localhost 2>/dev/null || true)"

  if [ "$http_code" = "200" ]; then
    record_result "HEALTHY" "HTTP response" "localhost returned HTTP 200"
  else
    record_result "FAIL" "HTTP response" "localhost returned ${http_code:-no response}"
  fi
}

check_disk() {
  local disk_usage
  disk_usage="$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')"

  if [ "$disk_usage" -ge "$DISK_FAIL" ]; then
    record_result "FAIL" "Root disk usage" "${disk_usage}% used"
  elif [ "$disk_usage" -ge "$DISK_WARN" ]; then
    record_result "WARN" "Root disk usage" "${disk_usage}% used"
  else
    record_result "HEALTHY" "Root disk usage" "${disk_usage}% used"
  fi
}

check_memory() {
  local memory_usage
  memory_usage="$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')"

  if [ "$memory_usage" -ge "$MEMORY_FAIL" ]; then
    record_result "FAIL" "Memory usage" "${memory_usage}% used"
  elif [ "$memory_usage" -ge "$MEMORY_WARN" ]; then
    record_result "WARN" "Memory usage" "${memory_usage}% used"
  else
    record_result "HEALTHY" "Memory usage" "${memory_usage}% used"
  fi
}

print_summary() {
  local overall_status

  if [ "$fail_count" -gt 0 ]; then
    overall_status="FAIL"
    exit_code=2
  elif [ "$warn_count" -gt 0 ]; then
    overall_status="WARN"
    exit_code=1
  else
    overall_status="HEALTHY"
    exit_code=0
  fi

  {
    echo
    echo "Summary"
    echo "Healthy: $healthy_count"
    echo "Warnings: $warn_count"
    echo "Failures: $fail_count"
    echo "Overall status: $overall_status"
    echo "Report: $REPORT_FILE"
  } | tee -a "$REPORT_FILE"
}

echo "Linux Health Triage Report" | tee -a "$REPORT_FILE"
echo "Operator: $FULL_NAME" | tee -a "$REPORT_FILE"
echo "Generated: $(date)" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"
# Script owner: Matthew Bardi
for check in "${checks[@]}"; do
  "$check"
done

print_summary
exit "$exit_code"
