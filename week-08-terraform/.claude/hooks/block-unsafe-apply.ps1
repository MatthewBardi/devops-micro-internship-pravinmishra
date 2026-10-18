# Blocks Claude Code from running terraform apply
# when the latest Terraform drift review has failed.

$callInput = [Console]::In.ReadToEnd() | ConvertFrom-Json
$command = $callInput.tool_input.command

$reportPath = Join-Path `
    $env:CLAUDE_PROJECT_DIR `
    "AI Assignment\reports\latest-report.txt"

$isTerraformApply = $command -match '(?i)\bterraform(?:\.exe)?\b.*\bapply\b'

if ($isTerraformApply -and (Test-Path $reportPath)) {
    $report = Get-Content $reportPath -Raw

    if ($report -match 'Overall Status:\s*FAIL') {
        @{
            hookSpecificOutput = @{
                hookEventName = "PreToolUse"
                permissionDecision = "deny"
                permissionDecisionReason = "terraform apply blocked: the latest drift review has Overall Status: FAIL. Review and resolve the findings before applying infrastructure changes."
            }
        } | ConvertTo-Json -Depth 4 -Compress

        exit 0
    }
}

exit 0