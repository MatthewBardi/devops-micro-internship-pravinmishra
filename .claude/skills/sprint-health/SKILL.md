---
name: sprint-health
description: Analyze the current Jira sprint and report sprint velocity, at-risk stories, and issues missing estimates without modifying Jira.
allowed-tools: mcp__jira__jira_get_agile_boards, mcp__jira__jira_get_sprints_from_board, mcp__jira__jira_search, mcp__jira__jira_get_sprint_issues, Read
disable-model-invocation: true
---

# Sprint Health

Analyze the current active Jira sprint for project GJMB using read-only Jira MCP tools.

## Safety Boundary

- Read Jira data only.
- Never create an issue.
- Never update or edit an issue.
- Never transition an issue.
- Never add a comment.
- Never modify story points or any Jira field.
- Never use Write.
- If a board change is needed, recommend the change and leave the action to the human.

## Gather

1. Find the Jira agile board for project GJMB.
2. Find the current active sprint.
3. Retrieve all issues in that sprint.
4. Gather each issue's:
   - Key
   - Summary
   - Status
   - Story points / estimate

## Analyze

Calculate and report:

### Sprint Velocity / Progress

- Total committed story points
- Completed story points
- Remaining story points
- Percentage of committed points completed

### Stories at Risk

Flag unfinished Sprint stories as potentially at risk, especially stories still in To Do or In Progress.

For each at-risk item, explain the reason based only on the live Jira data.

### Missing Estimates

List any Sprint issues that do not have Story Points.

If none are missing estimates, explicitly state that all Sprint stories are estimated.

## Output

Return a concise report with these sections:

### Sprint Summary

Include Sprint name and current state.

### Velocity

Show committed, completed, remaining, and completion percentage.

### At-Risk Stories

List issue key, summary, status, points, and reason.

### Missing Estimates

List issues without estimates or state that none are missing.

### Read-Only Confirmation

End with:

`No Jira issues were created, edited, commented on, or transitioned by this skill.`
