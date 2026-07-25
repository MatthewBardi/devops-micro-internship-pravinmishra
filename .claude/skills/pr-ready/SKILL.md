---
name: pr-ready
description: Review staged Git changes for Pull Request readiness and draft a PR title and description.
allowed-tools: Bash, Read, Grep
disable-model-invocation: true
---

# PR Ready Check

Review only the changes currently staged in Git.

## Safety Rules

- Do not write or modify any file.
- Do not stage or unstage files.
- Do not create a commit.
- Do not push changes.
- Do not open a Pull Request.
- Only gather information, analyze it, and provide recommendations.

## Gather

Use Git commands to inspect:

- `git status --short`
- `git diff --cached --name-only`
- `git diff --cached --stat`
- `git diff --cached`

Read staged files when additional context is required.

## Analyze

Check the staged changes for:

- Secret-like values, access keys, tokens, passwords, or private keys
- Debug statements such as `console.log`, `print`, or temporary logging
- Large or unrelated changes mixed into one commit
- Missing context or unclear intent
- Accidental generated files or sensitive information
- Changes that may need tests or documentation

## Output

Return the following sections:

### Staged Changes

Summarize the staged files and what changed.

### Risk Report

List each issue found with its filename and explanation.  
If no meaningful risks are found, state: `No significant risks found.`

### Suggested Pull Request Title

Draft one concise PR title.

### Suggested Pull Request Description

Draft a clear PR description containing:

- Summary
- Changes
- Testing or verification
- Risks or items worth reviewing

### Human Review Checklist

List a few things the user should verify before committing or opening the Pull Request.