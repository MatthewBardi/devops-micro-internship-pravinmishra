# Assignment 5 — AI-Assisted Sprint Health Report via Jira MCP

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will connect Claude Code to your Jira board through an MCP server, the same way you connected it to GitHub in Week 2, and build a read-only `/sprint-health` skill. The skill reads your current sprint through Jira's API and reports sprint velocity, stories at risk of missing the sprint, and items missing an estimate — but it must never create, edit, comment on, or transition a single ticket itself. You will prove that boundary holds by making a real change on the board yourself and confirming the skill only ever reports, never acts.

---

# Task 1 — Create a Jira API Token

## Goal

Generate an API token from your Atlassian account that the MCP server will use to authenticate with your Jira site. Do not screenshot the token value itself.

### Evidence

#### Screenshot 1 — Jira API token creation confirmation page showing the token name, with the token value not visible

![Screenshot 1 - Jira API token created](screenshots/15-assignment5-jira-api-token.png)

### Notes You Must Write (Very Important):

Why does the MCP server need your site URL and account email in addition to the token?

The MCP server needs the Jira site URL to know which Atlassian Cloud tenant to connect to, and it needs the account email to identify which Jira user is authenticating. The API token acts as the secret credential for that account. Together, the site URL, email, and token allow the server to authenticate to the correct Jira Cloud instance.

---

# Task 2 — Create .mcp.json at the Project Root

## Goal

Create or update `.mcp.json` at your project root with a Jira MCP server block, following the same shape as the GitHub MCP server you configured in Week 2.

### Evidence

#### Screenshot 2 — `.mcp.json` open in VS Code showing the Jira server configuration

![Screenshot 2 - Jira MCP configuration](screenshots/16-assignment5-mcp-json.png)

### Notes You Must Write (Very Important):

Compare this jira block to the github block from Week 2 Assignment 5. The GitHub server ran via npx (a Node.js package); this one runs via uvx (a Python package) — what stays exactly the same shape despite that difference, and why doesn't Claude Code care which language a given MCP server is written in?

The structure stays the same: both configurations use `mcpServers`, a named server block, `command`, `args`, and `env`. The GitHub MCP server used `npx` to launch a Node.js package, while the Jira MCP server uses `uvx` to launch a Python package. Claude Code does not care which programming language the server is written in because it communicates with the server through the standardized Model Context Protocol rather than through the server's implementation language.

---

# Task 3 — Add Your Credentials to settings.local.json

## Goal

Add your Jira site URL, account email, and API token to `.claude/settings.local.json`, and confirm that file is listed in `.gitignore` so it is never committed.

### Evidence

#### Screenshot 3 — `settings.local.json` open in VS Code showing the `env` section, with the actual token value blurred or covered

![Screenshot 3 - Jira credentials in settings.local.json with token redacted](screenshots/17-assignment5-settings-local-redacted.png)

### Notes You Must Write (Very Important):

Why must JIRA_API_TOKEN live in settings.local.json and never in .mcp.json?

`JIRA_API_TOKEN` is a secret credential and must remain in `.claude/settings.local.json`, which is gitignored and specific to my local environment. `.mcp.json` is project configuration that can be committed and shared with the repository, so storing the API token there could expose the credential in Git history or GitHub.

---

# Task 4 — Verify the Connection with /mcp

## Goal

Restart Claude Code and confirm the Jira MCP server shows as connected.

### Evidence

#### Screenshot 4 — `/mcp` output showing `jira: connected`

![Screenshot 4 - Jira MCP connected](screenshots/18-assignment5-mcp-connected.png)

---

# Task 5 — Run a Live Query to Prove Real Board Data

## Goal

Ask Claude to list the issues in your current active sprint through the Jira MCP connection, and confirm the result matches what you see on your live board in the browser.

### Evidence

#### Screenshot 5 — Claude's response showing the live sprint issue list retrieved via Jira MCP

![Screenshot 5 - Live Jira sprint query](screenshots/19-assignment5-live-sprint-query.png)

### Notes You Must Write (Very Important):

How did you confirm this was real board data and not something Claude guessed?

I compared Claude's Jira MCP result with the live Gotto Job Jira board in the browser. Both showed GJMB-2 as Done, GJMB-3 as To Do, and GJMB-4 as To Do, with the same Sprint membership and Story Point values. Because the MCP result matched the current browser state, I confirmed that Claude was reading live Jira data rather than guessing.

---

# Task 6 — Build the /sprint-health Skill

## Goal

Create a `/sprint-health` skill restricted to read-only Jira tools plus `Read`, with no issue-mutating tools and no `Write`. Run it and confirm it produces a report covering sprint velocity, at-risk stories, and items missing an estimate.

### Evidence

#### Screenshot 6 — `SKILL.md` frontmatter showing `allowed-tools` limited to read-only Jira tools plus `Read`, with `disable-model-invocation: true`

![Screenshot 6 - sprint-health SKILL.md read-only frontmatter](screenshots/20-assignment5-sprint-health-skill.png)

#### Screenshot 7 — `/sprint-health` output showing the full triage report against your real sprint

![Screenshot 7 - sprint-health report](screenshots/21-assignment5-sprint-health-report.png)

### Notes You Must Write (Very Important):

1. Which Jira MCP tools does this skill's allowed-tools list include, and which mutating tools (create issue, update issue, transition issue, add comment) does it deliberately exclude?

The skill allows these Jira MCP read-only tools:

- `mcp__jira__jira_get_agile_boards`
- `mcp__jira__jira_get_sprints_from_board`
- `mcp__jira__jira_search`
- `mcp__jira__jira_get_sprint_issues`
- `Read`

It deliberately excludes issue-mutating tools such as create issue, update issue, transition issue, and add comment. It also excludes `Write`, so the skill can gather and analyze information but cannot modify Jira or local files.

2. Why does a Scrum Master need this restriction more than almost any other role in this course?

A Scrum Master needs this restriction because the role should inspect workflow, identify blockers and risks, and facilitate the team's process without silently changing the team's work. If an AI assistant could transition tickets, change estimates, or comment automatically, it could alter the Sprint state without the responsible team member making or approving that decision. Read-only access preserves transparency and human accountability.

---

# Task 7 — Prove the Skill Never Mutates the Board

## Goal

Manually update one ticket on your board in the browser (for example, move a story to "Done" or add a missing estimate), then run `/sprint-health` again and confirm the new report reflects your change — proving the skill only ever reads live state and never wrote to the board itself.

### Evidence

#### Screenshot 8 — Second `/sprint-health` run showing the report now reflects your manual board change

![Screenshot 8 - sprint-health reflects manual Jira change](screenshots/22-assignment5-sprint-health-after-manual-change.png)

### Notes You Must Write (Very Important):

Map this assignment to Gather → Analyze → Human Act → Verify from Week 3 Assignment 6. Which step did you perform manually in the browser, and why must that step stay human?

The workflow maps to Gather -> Analyze -> Human Act -> Verify as follows:

- **Gather:** `/sprint-health` read the current Sprint data from Jira.
- **Analyze:** The skill calculated Sprint progress and identified at-risk work.
- **Human Act:** I manually changed GJMB-3 from To Do to In Progress in the Jira browser.
- **Verify:** I ran `/sprint-health` again and confirmed that the new report detected GJMB-3 as In Progress.

The Human Act step must remain human because changing ticket status changes the team's official system of record. The AI may recommend an action, but the accountable user should decide and perform the change.

---

# Submission Instructions

Complete all tasks in sequence.

Your submission must include:
- All 8 required screenshots
- All the required notes

---

# Completion Checklist

- [x] Task 1: Jira API token created, value never screenshotted (Screenshot 1)
- [x] Task 2: `.mcp.json` has the Jira server block (Screenshot 2)
- [x] Task 3: Credentials stored in `settings.local.json`, token blurred, file gitignored (Screenshot 3)
- [x] Task 4: `/mcp` shows the Jira server connected (Screenshot 4)
- [x] Task 5: Live query returned real sprint data, verified against the browser (Screenshot 5)
- [x] Task 6: `/sprint-health` skill created with correct read-only `allowed-tools`, and produced a full report (Screenshots 6–7)
- [x] Task 7: A manual board change was reflected in a second `/sprint-health` run (Screenshot 8)
- [x] Skill never created, edited, transitioned, or commented on any issue
- [x] Reflection answered (Notes)
- [x] No API token value exposed

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
