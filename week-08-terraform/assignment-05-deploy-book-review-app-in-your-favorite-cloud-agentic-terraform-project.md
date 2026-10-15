# Capstone Assignment — Deploy the Book Review App Using Terraform and Claude Code Agentic AI

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Student Details

**Full Name:** Matthew Bardi
**Cloud Platform:** AWS or Azure
**GitHub Repository URL:** https://github.com/MatthewBardi/devops-micro-internship-pravinmishra
**Public Application URL / Load-Balancer DNS:** Add the public URL or DNS here

---

## Purpose

Deploy the Book Review App using Terraform on AWS or Azure in a secure, highly available, production-style three-tier architecture. Use Claude Code, specialized subagents, Terraform MCP, and validation hooks to support the engineering workflow while keeping all infrastructure-changing operations under human control.

---

# Task 0 — Prepare the Project and Agentic AI Environment

## Goal

Prepare the Book Review App project and configure the provided Claude Code Agentic AI starter kit with project context, specialized subagents, Terraform MCP, validation hooks, and safety guardrails.

## Evidence

### Screenshot 1 — Project `CLAUDE.md`

Add a screenshot of the project `CLAUDE.md` showing the three-tier architecture, security boundaries, Terraform requirements, and human-approval rules.

![Screenshot 1 - Project CLAUDE.md](screenshots/week-08-assignment-05-screenshot-01-claude-md.png)

---

### Screenshot 2 — Terraform Engineer Subagent

Add a screenshot showing the Terraform Engineer subagent configuration.

![Screenshot 2 - Terraform Engineer Subagent](screenshots/week-08-assignment-05-screenshot-02-terraform-engineer.png)

---

### Screenshot 3 — Architecture and Security Reviewer Subagent

Add a screenshot showing the Architecture and Security Reviewer subagent configuration.

![Screenshot 3 - Architecture and Security Reviewer Subagent](screenshots/week-08-assignment-05-screenshot-03-security-reviewer.png)

---

### Screenshot 4 — Terraform MCP Connection

Add a screenshot showing Terraform MCP connected and available.

![Screenshot 4 - Terraform MCP Connection](screenshots/week-08-assignment-05-screenshot-04-terraform-mcp-connected.png)

---

### Screenshot 5 — Validation Hooks

Add a screenshot showing the configured Claude Code validation hooks.

![Screenshot 5 - Validation Hooks](screenshots/week-08-assignment-05-screenshot-05-validation-hooks.png)

---

# Task 1 — Design the Three-Tier Architecture

## Goal

Design the required secure, highly available three-tier architecture and create an architecture diagram before building the infrastructure.

The diagram must show:

- VPC or VNet
- Availability Zones or equivalent availability locations
- Six subnets
- Internet connectivity
- NAT or outbound design
- Public load balancer
- Web Tier
- Internal load balancer
- Application Tier
- Managed MySQL
- Read replica
- Main traffic flow

## Architecture Diagram

```mermaid
flowchart TB

    Internet["Internet Users"]

    subgraph VPC["AWS VPC - 10.0.0.0/16"]

        IGW["Internet Gateway"]

        subgraph AZA["Availability Zone us-east-1a"]
            WEB1["Public Web Subnet<br/>10.0.1.0/24"]
            APP1["Private App Subnet<br/>10.0.11.0/24"]
            DB1["Private DB Subnet<br/>10.0.21.0/24"]
        end

        subgraph AZB["Availability Zone us-east-1b"]
            WEB2["Public Web Subnet<br/>10.0.2.0/24"]
            APP2["Private App Subnet<br/>10.0.12.0/24"]
            DB2["Private DB Subnet<br/>10.0.22.0/24"]
        end

        PUBALB["Public Application Load Balancer"]
        WEBASG["Web Tier<br/>Next.js + Nginx<br/>Auto Scaling Group"]
        INTALB["Internal Application Load Balancer"]
        APPASG["Application Tier<br/>Node.js / Express - Port 3001<br/>Auto Scaling Group"]
        NAT1["NAT Gateway - AZ 1"]
        NAT2["NAT Gateway - AZ 2"]
        RDS["Amazon RDS MySQL<br/>Multi-AZ Primary / Standby"]
        REPLICA["RDS Read Replica"]

        IGW --> PUBALB
        PUBALB --> WEBASG
        WEBASG --> INTALB
        INTALB --> APPASG
        APPASG --> RDS
        RDS --> REPLICA

        WEBASG --- WEB1
        WEBASG --- WEB2
        APPASG --- APP1
        APPASG --- APP2
        RDS --- DB1
        RDS --- DB2

        WEB1 --> NAT1
        WEB2 --> NAT2
        APP1 -. outbound only .-> NAT1
        APP2 -. outbound only .-> NAT2
        NAT1 --> IGW
        NAT2 --> IGW
    end

    Internet --> IGW
```

**Main application traffic flow:**
Internet → Public ALB → Web Tier → Internal ALB → Application Tier → Private RDS MySQL

---

# Task 2 — Build the Terraform Networking and Security Layers

## Goal

Create the modular Terraform project and implement the network and security layers across the required public and private subnets.

## Evidence

### Screenshot 6 — Modular Terraform Project Structure

Add a screenshot showing the modular Terraform project structure.

![Screenshot 6 - Modular Terraform Project Structure](screenshots/week-08-assignment-05-screenshot-06-terraform-project-structure.png)

---

### Screenshot 7 — Six-Subnet Architecture

Add a screenshot showing the six-subnet architecture across two availability locations.

![Screenshot 7 - Six-Subnet Architecture](screenshots/week-08-assignment-05-screenshot-07-network-configuration.png)

---

### Screenshot 8 — Public and Private Tier Separation

Add a screenshot showing the public and private tier separation, including routing and security boundaries.

![Screenshot 8 - Public and Private Tier Separation](screenshots/week-08-assignment-05-screenshot-08-network-security.png)

---

# Task 3 — Build the Load-Balancing and Compute Layers

## Goal

Deploy the public and internal load balancers and the Web and Application compute resources required by the Book Review App.

## Evidence

### Screenshot 9 — Web and Application Compute

Add a screenshot showing the Web and Application compute resources in their required subnets.

![Screenshot 9 - Web and Application Compute](screenshots/week-08-assignment-05-screenshot-09.png)

---

### Screenshot 10 — Public Load Balancer

Add a screenshot showing the internet-facing public load balancer.

![Screenshot 10 - Public Load Balancer](screenshots/week-08-assignment-05-screenshot-10.png)

---

### Screenshot 11 — Internal Load Balancer

Add a screenshot showing the private internal load balancer.

![Screenshot 11 - Internal Load Balancer](screenshots/week-08-assignment-05-screenshot-11.png)

---

### Screenshot 12 — Healthy Targets

Add a screenshot showing healthy target groups or backend pools.

![Screenshot 12 - Healthy Targets](screenshots/week-08-assignment-05-screenshot-12.png)

---

# Task 4 — Build the Managed MySQL Database Layer

## Goal

Deploy a private, highly available managed MySQL database with a read replica and restrict database connectivity to the Application Tier.

## Evidence

### Screenshot 13 — Managed MySQL Database

Add a screenshot showing the managed MySQL database deployment.

![Screenshot 13 - Managed MySQL Database](screenshots/week-08-assignment-05-screenshot-13.png)

---

### Screenshot 14 — High Availability

Add a screenshot showing the Multi-AZ or high-availability configuration.

![Screenshot 14 - High Availability](screenshots/week-08-assignment-05-screenshot-14.png)

---

### Screenshot 15 — Read Replica

Add a screenshot showing the read replica configuration.

![Screenshot 15 - Read Replica](screenshots/week-08-assignment-05-screenshot-15.png)

---

### Screenshot 16 — Private Database Access

Add a screenshot showing that the database is private and accepts MySQL traffic only from the Application Tier.

![Screenshot 16 - Private Database Access](screenshots/week-08-assignment-05-screenshot-16.png)

---

# Task 5 — Validate, Review, and Apply the Terraform Configuration

## Goal

Validate the Terraform configuration, review the execution plan using both Agentic AI and human judgment, and apply the infrastructure changes only after all required checks pass.

## Evidence

### Screenshot 17 — Terraform Validation

Add a screenshot showing successful `terraform validate` output.

![Screenshot 17 - Terraform Validation](screenshots/week-08-assignment-05-screenshot-17-terraform-validation.png)

---

### Screenshot 18 — Terraform Plan

Add a screenshot showing the Terraform plan output.

![Screenshot 18 - Terraform Plan](screenshots/week-08-assignment-05-screenshot-18-terraform-plan.png)

---

### Screenshot 19 — Terraform Apply

Add a screenshot showing successful `terraform apply` completion.

![Screenshot 19 - Terraform Apply](screenshots/week-08-assignment-05-screenshot-19.png)

---

# Task 6 — Deploy and Configure the Book Review Application

## Goal

Deploy and configure the Book Review App across the Web, Application, and Database tiers and verify the complete application functionality.

## Evidence

### Screenshot 20 — Homepage

Add a screenshot showing the Book Review App homepage through the public endpoint.

![Screenshot 20 - Book Review App Homepage](screenshots/week-08-assignment-05-screenshot-20.png)

---

### Screenshot 21 — Login or Authentication

Add a screenshot showing successful login or authentication.

![Screenshot 21 - Successful Login](screenshots/week-08-assignment-05-screenshot-21.png)

---

### Screenshot 22 — Book Data

Add a screenshot showing the book listing or book details.

![Screenshot 22 - Book Data](screenshots/week-08-assignment-05-screenshot-22.png)

---

### Screenshot 23 — Review Functionality

Add a screenshot showing the review functionality working successfully.

![Screenshot 23 - Review Functionality](screenshots/week-08-assignment-05-screenshot-23.png)

---

### Screenshot 24 — Backend or API Evidence

Add a screenshot showing that the backend or API is working successfully.

![Screenshot 24 - Backend API Evidence](screenshots/week-08-assignment-05-screenshot-24.png)

---

### Screenshot 25 — Database Reads and Writes

Add a screenshot showing successful database reads and writes.

![Screenshot 25 - Database Reads and Writes](screenshots/week-08-assignment-05-screenshot-25.png)

## Public Application URL

**Public Application URL / DNS:** Add the working public application URL or load-balancer DNS here

---

# Task 7 — Demonstrate the Agentic AI Workflow

## Goal

Demonstrate how Claude Code assisted with Terraform generation, architecture and security review, and evidence-based troubleshooting while infrastructure-changing decisions remained under human control.

You do not need to submit your complete Claude Code conversation history. Include only focused evidence.

## Evidence

### Screenshot 26 — AI-Assisted Terraform Generation

Add a screenshot showing one useful example of AI-assisted Terraform generation or improvement.

![Screenshot 26 - AI-Assisted Terraform Generation](screenshots/week-08-assignment-05-screenshot-26-ai-assisted-terraform.png)

---

### Screenshot 27 — Architecture or Security Review

Add a screenshot showing one structured architecture or security review result.

![Screenshot 27 - Architecture and Security Review](screenshots/week-08-assignment-05-screenshot-27-security-review.png)

---

### Screenshot 28 — AI-Assisted Troubleshooting

Add a screenshot showing one AI-assisted troubleshooting interaction based on collected evidence.

![Screenshot 28 - AI-Assisted Troubleshooting](screenshots/week-08-assignment-05-screenshot-28.png)

---

# Task 8 — Complete the Final Architecture Review

## Goal

Review the completed infrastructure against the original capstone requirements and resolve significant architecture, security, reliability, and cost issues.

Confirm that the final review covers:

- Tier separation
- Availability
- Public exposure
- Routing
- Security rules
- Load balancing
- Database privacy
- Secrets
- Terraform quality
- Module structure
- Reliability
- Obvious cost risks

Use Screenshot 27 as the focused evidence for the structured architecture or security review.

---

# Task 9 — Answer the Reflection Questions

## Goal

Reflect on the architecture, Terraform implementation, and Agentic AI workflow. Answer each question briefly in your own words.

## Architecture

### 1. Why did you separate the Web, Application, and Database tiers?

I separated the Web, Application, and Database tiers so each layer has a specific responsibility and can be secured independently. The Web Tier handles user-facing traffic, the Application Tier processes business logic, and the Database Tier stores application data.

### 2. Why is the Application Tier private?

The Application Tier is private because it does not need direct access from the internet. Requests reach it through the internal load balancer from the Web Tier, which reduces unnecessary public exposure.

### 3. Why is MySQL private?

MySQL is private because only the Application Tier needs to communicate with the database. Keeping RDS private prevents direct internet access and limits MySQL traffic to the required application path.

### 4. Why are multiple Availability Zones used?

I used multiple Availability Zones to improve availability and resilience. If resources in one Availability Zone become unavailable, resources in the other Availability Zone can continue supporting the application.

### 5. What is the difference between Multi-AZ/high availability and a read replica?

Multi-AZ is primarily used for database high availability and failover by maintaining a standby copy. A read replica is primarily used for read scaling by providing another database instance that can serve read traffic.

## Terraform

### 6. How did you divide your Terraform into modules?

I divided the Terraform configuration into logical modules for networking, security, load balancing, compute, and database resources. This kept each infrastructure responsibility organized and easier to maintain.

### 7. How do the modules communicate through variables and outputs?

Terraform modules communicate through variables and outputs. For example, the network module outputs VPC and subnet IDs, and those values are passed as inputs to the security, load-balancer, compute, and database modules.

### 8. What did you specifically check in `terraform plan`?

I checked the Terraform plan for the resources being created, unexpected deletions or replacements, public exposure, subnet placement, security-group rules, ports 3001 and 3306, database settings, dependencies, Availability Zones, and possible cost risks.

## Agentic AI

### 9. What was the purpose of `CLAUDE.md`?

CLAUDE.md provided Claude Code with the project architecture, Terraform requirements, security boundaries, secret-handling rules, validation requirements, and the requirement that infrastructure-changing operations remain under human control.

### 10. What work did the Terraform Engineer subagent perform?

The Terraform Engineer subagent helped with Terraform architecture planning, module design, resource configuration, variables and outputs, module relationships, provider research, validation problems, and Terraform improvements.

### 11. What did the Architecture and Security Reviewer identify?

The Architecture and Security Reviewer checked tier separation, networking, public exposure, routing, security groups, load balancing, database privacy, secrets, Terraform structure, reliability, and cost risks. The final review passed with non-blocking warnings such as HTTP-only ALB traffic, EC2 health checks for Auto Scaling Groups, a Single-AZ read replica, and lab-oriented cost and deletion settings.

### 12. Why did you use Terraform MCP instead of relying only on Claude's existing Terraform knowledge?

I used Terraform MCP so Claude could reference current Terraform provider and resource documentation instead of relying only on previously learned information that could be outdated. This helped reduce the risk of using incorrect or deprecated Terraform configuration.

### 13. What was the purpose of your validation hooks?

The validation hooks provided deterministic checks whenever Terraform files were changed. They helped run formatting and validation automatically while also preventing Claude from silently running terraform apply or terraform destroy.

### 14. Describe one real issue Claude helped you troubleshoot.

One real issue Claude helped me troubleshoot was an RDS deployment problem related to the AWS account plan and database configuration. I provided the actual Terraform error, reviewed the diagnosis, verified the likely cause, and made a controlled change before retrying the deployment.

### 15. Describe one recommendation you reviewed, modified, or rejected instead of accepting blindly.

I did not automatically accept every recommendation. When the RDS deployment encountered account-plan restrictions, I reviewed the available options instead of reducing the architecture requirements. Because the assignment required Multi-AZ and a read replica, I kept the required design, completed the deployment, validated it, and later destroyed the lab resources to control cost.

---

# Task 10 — Publish the Mandatory LinkedIn Post

## Goal

Publish a LinkedIn post describing the capstone, the technical work completed, the Agentic AI workflow, and the lessons learned.

Write the post in your own words, include at least one project image or other proof, and ensure that it can be viewed by the submission reviewer.

## LinkedIn Post URL

**LinkedIn Post URL:** https://www.linkedin.com/feed/update/urn:li:activity:7516528165020684289/

---

# Submission Instructions

- Complete Tasks 0–10 in sequence.
- Include all Screenshots 1–28 exactly as specified.
- Ensure that your full name is visible in the required screenshots.
- Include the selected cloud platform.
- Include the completed architecture diagram.
- Include the modular Terraform project structure.
- Include the working public application URL or public load-balancer DNS.
- Include all required Agentic AI workflow evidence.
- Answer all 15 reflection questions briefly in your own words.
- Include the published LinkedIn post URL.
- Do not expose cloud credentials, database passwords, SSH private keys, JWT secrets, access tokens, account IDs, Terraform state containing sensitive values, or other confidential information.
- Review all screenshots and project files carefully before submitting through GitHub.

---

# Completion Checklist

- [ ] Selected AWS or Azure
- [ ] Added and reviewed the Agentic AI starter files
- [ ] Configured `CLAUDE.md`
- [ ] Configured the Terraform Engineer subagent
- [ ] Configured the Architecture and Security Reviewer subagent
- [ ] Connected Terraform MCP
- [ ] Configured validation hooks and safety guardrails
- [ ] Created the architecture diagram
- [ ] Created the six-subnet design
- [ ] Configured public Web Tier routing
- [ ] Kept the Application Tier private
- [ ] Kept the Database Tier private
- [ ] Configured tier-specific Security Groups or NSGs
- [ ] Restricted backend port `3001`
- [ ] Restricted MySQL port `3306` to the Application Tier
- [ ] Created the public load balancer
- [ ] Created the internal load balancer
- [ ] Configured listeners and health checks
- [ ] Deployed the Web Tier compute resources
- [ ] Deployed the private Application Tier compute resources
- [ ] Provisioned private managed MySQL
- [ ] Configured Multi-AZ or high availability
- [ ] Configured a read replica
- [ ] Created the modular Terraform project
- [ ] Used variables, outputs, and module dependencies
- [ ] Used current Terraform documentation through MCP
- [ ] Used hooks for deterministic validation
- [ ] Completed `terraform fmt`
- [ ] Completed `terraform validate`
- [ ] Reviewed `terraform plan`
- [ ] Completed the Terraform Engineer review
- [ ] Completed the Architecture and Security review
- [ ] Applied the infrastructure only after human approval
- [ ] Deployed and configured the backend
- [ ] Deployed and configured the frontend
- [ ] Configured Nginx where required
- [ ] Configured the internal backend endpoint
- [ ] Configured the public frontend endpoint
- [ ] Verified the homepage
- [ ] Verified login or authentication
- [ ] Verified book data
- [ ] Verified review functionality
- [ ] Verified the backend API
- [ ] Verified database reads and writes
- [ ] Verified healthy load-balancer targets
- [ ] Included AI-assisted Terraform generation evidence
- [ ] Included one architecture or security review
- [ ] Included one AI-assisted troubleshooting example
- [ ] Completed the final architecture review
- [ ] Answered all 15 reflection questions
- [ ] Published the mandatory LinkedIn post
- [ ] Added the LinkedIn post URL
- [ ] Captured all 28 required screenshots
- [ ] Confirmed that my full name is visible in the required screenshots
- [ ] Checked that no secrets or sensitive information are exposed

---

## About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory), focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations through hands-on experience.

---

## Resources

- Book Review App Repository: [https://github.com/pravinmishraaws/book-review-app](https://github.com/pravinmishraaws/book-review-app)
- DMI Official Website: [https://dmi.pravinmishra.com](https://dmi.pravinmishra.com)
- University: [https://university.pravinmishra.com](https://university.pravinmishra.com)
- Discord Community: [https://discord.pravinmishra.com](https://discord.pravinmishra.com)
- Blog: [https://dmi.pravinmishra.com/blog](https://dmi.pravinmishra.com/blog)
- YouTube Playlist: [https://www.youtube.com/playlist?list=PLFeSNDtI4Cho](https://www.youtube.com/playlist?list=PLFeSNDtI4Cho)
- Pravin Mishra on LinkedIn: [https://www.linkedin.com/in/pravin-mishra-aws-trainer/](https://www.linkedin.com/in/pravin-mishra-aws-trainer/)
- CloudAdvisory on LinkedIn: [https://www.linkedin.com/company/thecloudadvisory/](https://www.linkedin.com/company/thecloudadvisory/)

---

*This submission is part of the DevOps Micro Internship (DMI) Cohort 3 — Agentic AI Track.*
