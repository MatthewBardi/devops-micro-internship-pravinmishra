# Assignment 3 — Multi-Play Web Deploy on Azure

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will create one Ansible playbook (`site.yml`) with three plays — install Nginx, deploy a static website with the `copy` module, and verify the deployment from the controller — against the `[web]` group from your existing inventory.

---

# Task 1 — Set Up Folder Layout

## Goal

Create the `static-web` project directory with `inventory.ini`, `site.yml`, a `files/` subdirectory, and `README.md`.

### Evidence

#### Screenshot 1 — Terminal or editor showing the complete `static-web` folder layout

![Screenshot 1 - Project structure](screenshots/assignment-03-01-project-structure.png)

---

# Task 2 — Get the Content

## Goal

Stage `index.html` from `https://github.com/pravinmishraaws/Azure-Static-Website` locally under `static-web/files/`.

### Evidence

#### Screenshot 2 — Editor or terminal showing `files/index.html` staged inside the `static-web` project

![Screenshot 2 - Website HTML](screenshots/assignment-03-02-index-html.png)

---

# Task 3 — Create the Multi-Play Playbook: site.yml

## Goal

Write `site.yml` with three plays: Play 1 (install/start Nginx on `web`), Play 2 (`copy` `files/index.html` to `/var/www/html/index.html` with owner `www-data`/mode `0644`, notifying an Nginx reload handler), and Play 3 (verify every web host with the `uri` module from `localhost`, asserting HTTP 200).

### Evidence

#### Screenshot 3 — Editor showing the three plays in `site.yml`

![Screenshot 3 - Three Ansible plays](screenshots/assignment-03-03-three-plays.png)

---

#### Screenshot 4 — Editor showing the copy task, file ownership/mode, handler, uri task, and HTTP 200 assertion

![Screenshot 4A - Copy task and Nginx handler](screenshots/assignment-03-04a-copy-handler.png)

![Screenshot 4B - HTTP verification tasks](screenshots/assignment-03-04b-http-verification-code.png)

---

# Task 4 — Run the Playbook

## Goal

Run `ansible-playbook -i inventory.ini site.yml` and confirm all plays complete with no failures.

### Evidence

#### Screenshot 5 — Terminal showing the `ansible-playbook` run and final recap with OK/changed results and no failures

![Screenshot 5 - Successful playbook recap](screenshots/assignment-03-05-playbook-success.png)

---

#### Screenshot 6 — Terminal showing the successful localhost URI verification results

![Screenshot 6 - HTTP 200 verification](screenshots/assignment-03-06-http-200-verification.png)

---

# Task 5 — Manual Verification

## Goal

Confirm the deployed static website is reachable directly from a web-server public IP via `curl` and a browser.

### Evidence

#### Screenshot 7 — Browser showing the static website loaded from a web-server public IP

![Screenshot 7 - Web1 browser verification](screenshots/assignment-03-07-website-browser.png)

Additional verification - Web2:

![Web2 browser verification](screenshots/assignment-03-07-web2-browser.png)

---

### Notes

Describe an issue you faced and how you fixed it, what you learned, why installation and deployment were split into separate plays, and one benefit of using `copy` instead of cloning from Git directly.

**Issue encountered and resolution:** During deployment, Ansible initially failed to connect to the EC2 instances because my public IP address changed repeatedly. I updated the AWS security group SSH restrictions using Terraform and reloaded my passphrase-protected SSH key into the SSH agent. After restoring connectivity, the playbook executed successfully on both web servers.

**What I learned:** I learned how to structure an Ansible playbook into multiple plays, automate Nginx installation, deploy static website files, use handlers, and verify HTTP 200 responses from the Ansible controller.

**Why installation and deployment were separated:** Separating these operations into different plays improves readability, troubleshooting, and maintainability. It also makes the automation easier to extend.

**Benefit of using the `copy` module:** The `copy` module deploys a known, locally staged version of the website, making deployments more predictable and avoiding a dependency on Git access from the target servers.

# Submission Instructions

- Add all required screenshots in your submission
- IP addresses in `inventory.ini` may be redacted
- Do not expose SSH private keys

---

# Completion Checklist

- [x] Task 1: `static-web` project structure created (Screenshot 1)
- [x] Task 2: `index.html` staged under `files/` (Screenshot 2)
- [x] Task 3: Three-play `site.yml` written (Screenshots 3–4)
- [x] Task 4: Playbook run successfully with no failures (Screenshots 5–6)
- [x] Task 5: Site verified manually via browser (Screenshot 7)
- [x] Reflection notes written (Notes)
- [x] No sensitive data exposed

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
