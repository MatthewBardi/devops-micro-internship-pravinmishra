# Linux Incident Summary

**Full Name:** Matthew Bardi

**Date:** 17/07/2026

## 1. Reported Symptom

The Nginx web service became unavailable. The service was inactive, port 80 was not listening, and the localhost HTTP request could not connect.

## 2. Evidence Collected

The Linux triage script reported three failures:

- Nginx service status was inactive.
- No listener was detected on port 80.
- The HTTP request to localhost returned code 000.

Disk usage and memory usage remained within the healthy thresholds.

## 3. Most Likely Cause

The most likely cause was that the Nginx service had been stopped. Because Nginx was not running, no process was listening on port 80 and the HTTP request could not connect.

## 4. Human-Approved Recovery Action

I manually executed the following recovery command:

`sudo systemctl start nginx`

Claude recommended the command but did not execute it.

## 5. Verification

After starting Nginx, I confirmed that the service status was active and that `curl -I http://localhost` returned `HTTP/1.1 200 OK`. I then ran `/linux-triage` again, and all five checks returned HEALTHY with zero warnings and zero failures.

## 6. Safety Decision

The AI was limited to gathering and analyzing evidence. The human operator reviewed and executed the recovery command, which prevented an unapproved system change.

## 7. Agentic Loop Mapping

- **Gather:** The Bash script collected the service, port, HTTP, disk, and memory evidence.
- **Analyze:** Claude interpreted the evidence and identified the stopped Nginx service as the most likely cause.
- **Human Act:** I manually started the Nginx service.
- **Verify:** The triage workflow was run again and confirmed that the server had returned to a healthy state.
