# Assignment 5 — Deploy a Highly Available Two-Tier Application on AWS (VPC + ALB + ASG + Multi-AZ RDS)

Part of the DevOps Micro Internship (DMI) Cohort 3 with Agentic AI

---

## Purpose

In this assignment, you will design and deploy a highly available two-tier web application on AWS: highly available networking across two Availability Zones, an Application Load Balancer, an Auto Scaling Group for the web tier, and a private Multi-AZ RDS database. You must prove high availability with real failure tests.

---

# Task 1 — Create HA Networking (VPC + 4 Subnets + IGW + NAT + Route Tables)

## Goal

Build a VPC (10.0.0.0/16) with two public and two private subnets across two Availability Zones, an Internet Gateway, a NAT Gateway, and the matching public/private route tables.

### Evidence

#### Screenshot 1 — VPC details showing CIDR 10.0.0.0/16

![Screenshot 1](screenshots/week-06-assignment-05-screenshot-01-vpc-details.png)

---

#### Screenshot 2 — Subnets list showing four subnets and their Availability Zones

![Screenshot 2](screenshots/week-06-assignment-05-screenshot-02-subnets.png)

---

#### Screenshot 3 — Public route table showing the Internet Gateway route and both public-subnet associations

![Screenshot 3](screenshots/week-06-assignment-05-screenshot-03-public-route-table.png)

---

#### Screenshot 4 — Private route table showing the NAT Gateway route and both private-subnet associations

![Screenshot 4](screenshots/week-06-assignment-05-screenshot-04-private-route-table.png)

---

#### Screenshot 5 — NAT Gateway status showing Available and the Elastic IP

![Screenshot 5](screenshots/week-06-assignment-05-screenshot-05-nat-gateway.png)

---

# Task 2 — Create Security Groups (ALB, EC2, RDS) with Least Privilege

## Goal

Create `ha-alb-sg` (HTTP public), `ha-web-sg` (HTTP only from `ha-alb-sg`, SSH from your IP), and `ha-db-sg` (database port only from `ha-web-sg`).

### Evidence

#### Screenshot 6 — ALB Security Group inbound rules

![Screenshot 6](screenshots/week-06-assignment-05-screenshot-06-alb-security-group.png)

---

#### Screenshot 7 — EC2 Security Group inbound rules showing the ALB Security Group reference and SSH from your IP

![Screenshot 7](screenshots/week-06-assignment-05-screenshot-07-web-security-group.png)

---

#### Screenshot 8 — RDS Security Group inbound rule showing the database port allowed only from the EC2 Security Group

![Screenshot 8](screenshots/week-06-assignment-05-screenshot-08-db-security-group.png)

---

# Task 3 — Deploy Database Tier (RDS Multi-AZ in Private Subnets)

## Goal

Launch a private, Multi-AZ RDS database (MySQL or PostgreSQL) using the private DB Subnet Group and `ha-db-sg`.

### Evidence

#### Screenshot 9 — RDS summary showing Multi-AZ = Yes and Publicly accessible = No

![Screenshot 9](screenshots/week-06-assignment-05-screenshot-09-rds-multi-az-private.png)

---

#### Screenshot 10 — RDS connectivity section showing the DB Subnet Group and Security Group

![Screenshot 10](screenshots/week-06-assignment-05-screenshot-10-rds-connectivity.png)

---

# Task 4 — Build a Launch Template (User Data Installs App + Connects to DB)

## Goal

Create a Launch Template whose user data installs the web-server runtime, deploys the application, configures the database connection, and starts the required services.

### Evidence

#### Screenshot 11 — Launch Template details showing that user data exists, including a visible snippet

![Screenshot 11](screenshots/week-06-assignment-05-screenshot-11-launch-template-user-data.png)

---

#### Screenshot 12 — A running instance created from the template showing that the application responds on port 80 through a local test or browser using its public IP

![Screenshot 12](screenshots/week-06-assignment-05-screenshot-12-launch-template-test.png)

---

# Task 5 — Create an Application Load Balancer (ALB) Across 2 Public Subnets

## Goal

Create an internet-facing ALB across both public subnets with an HTTP listener and a healthy instance target group.

### Evidence

#### Screenshot 13 — ALB details showing two public subnets in two Availability Zones

![Screenshot 13](screenshots/week-06-assignment-05-screenshot-13-alb-two-azs.png)

---

#### Screenshot 14 — Target group showing at least one healthy target

![Screenshot 14](screenshots/week-06-assignment-05-screenshot-14-healthy-target.png)

---

# Task 6 — Create Auto Scaling Group (ASG) in 2 Public Subnets

## Goal

Create an Auto Scaling Group from the Launch Template across both public subnets, with desired capacity 2, minimum 2, and maximum 4, registered to the ALB target group.

### Evidence

#### Screenshot 15 — Auto Scaling Group showing desired, minimum, and maximum capacity and the selected subnet Availability Zones

![Screenshot 15](screenshots/week-06-assignment-05-screenshot-15-auto-scaling-group.png)

---

#### Screenshot 16 — EC2 instances list showing two running instances in different Availability Zones

![Screenshot 16](screenshots/week-06-assignment-05-screenshot-16-two-asg-instances.png)

---

# Task 7 — Configure App to Use RDS + Validate Read/Write

## Goal

Confirm the application communicates with the RDS database through the ALB DNS name with at least one read and one write operation.

### Evidence

#### Screenshot 17 — Browser showing the application loaded through the ALB DNS name with the URL visible

![Screenshot 17](screenshots/week-06-assignment-05-screenshot-17-app-through-alb.png)

---

#### Screenshot 18 — Proof of a database write through a UI message or database query output

![Screenshot 18](screenshots/week-06-assignment-05-screenshot-18-database-write.png)

---

# Task 8 — High Availability Tests (Must Do Both)

## Goal

Test A: terminate one web instance and confirm the Auto Scaling Group replaces it automatically without interrupting the ALB.

Test B: simulate an Availability Zone impact (stop, detach, or reduce desired capacity in one AZ) and confirm the application stays available.

### Evidence

#### Screenshot 19 — EC2 showing the terminated instance and the newly launched instance; timestamps are helpful

![Screenshot 19](screenshots/week-06-assignment-05-screenshot-19-asg-instance-replacement.png)

---

#### Screenshot 20 — Target group showing healthy targets after replacement

![Screenshot 20](screenshots/week-06-assignment-05-screenshot-20-healthy-targets-after-replacement.png)

---

#### Screenshot 21 — Evidence that an instance was removed, detached, placed in Standby, or stopped in one Availability Zone

![Screenshot 21](screenshots/week-06-assignment-05-screenshot-21-az-standby-test.png)

---

#### Screenshot 22 — Browser showing that the ALB DNS endpoint still works during the change

![Screenshot 22](screenshots/week-06-assignment-05-screenshot-22-alb-still-available.png)

---

# Task 9 — Architecture and Test-Results Summary

## Goal

Summarize the VPC/subnet layout, the ALB and Auto Scaling Group setup, the private Multi-AZ RDS setup, and the results of both high-availability tests.

### Evidence

#### Screenshot 23 — A simple architecture diagram, which may be hand-drawn, or an AWS console overview showing the components

![Screenshot 23](screenshots/week-06-assignment-05-screenshot-23-architecture.png)

---

### Notes

Summarize the VPC and subnets across the two Availability Zones.

I created the ha-vpc with CIDR 10.0.0.0/16 across us-east-1a and us-east-1b. Each Availability Zone contains one public subnet and one private subnet. The public subnets route internet traffic through an Internet Gateway, while the private subnets use a NAT Gateway for outbound access.


Summarize the ALB and Auto Scaling Group setup.

I deployed an internet-facing Application Load Balancer across both public subnets and connected it to the ha-web-tg target group. The ha-web-asg Auto Scaling Group uses the launch template to maintain a minimum and desired capacity of 2 instances with a maximum of 4, distributing the web instances across both Availability Zones.

Summarize the private Multi-AZ RDS setup.

I deployed ha-mysql as a private Multi-AZ MySQL RDS database using a DB subnet group spanning both private subnets. Public access is disabled, and the database security group permits MySQL port 3306 only from the web-tier security group.

Summarize the results of both high-availability tests.

In Test A, I terminated one web instance and confirmed that the Auto Scaling Group automatically launched a replacement while the remaining instance continued serving traffic. In Test B, I placed the us-east-1a instance into Standby and confirmed that the application remained available through the ALB using the instance in us-east-1b. After testing, I restored the Auto Scaling Group to two InService instances.

---

# LinkedIn Post (Required)

## Goal

Publish a LinkedIn post about the high-availability build, including the ALB URL (or a redacted screenshot), three to five lines on what you built and how you tested high availability, and one proof screenshot.

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

https://www.linkedin.com/feed/update/urn:li:share:7497274922210168832/

---

#### Screenshot of LinkedIn post

![LinkedIn Post](screenshots/week-06-assignment-05-linkedin-post.png)

---

# Submission Instructions

- Add all required screenshots in your submission
- Do not expose passwords, connection strings, private keys, or account IDs

---

# Completion Checklist

- [x] Task 1: VPC, four subnets, IGW, NAT Gateway, and route tables created (Screenshots 1–5)
- [x] Task 2: Least-privilege ALB, EC2, and RDS security groups created (Screenshots 6–8)
- [x] Task 3: Private Multi-AZ RDS created (Screenshots 9–10)
- [x] Task 4: Self-configuring Launch Template created and tested (Screenshots 11–12)
- [x] Task 5: ALB created across both public subnets (Screenshots 13–14)
- [x] Task 6: Auto Scaling Group running two instances across two AZs (Screenshots 15–16)
- [x] Task 7: Application verified through the ALB with a database read and write (Screenshots 17–18)
- [x] Task 8: Both high-availability tests completed (Screenshots 19–22)
- [x] Task 9: Architecture and test-results summary completed (Screenshot 23 & Notes)
- [x] LinkedIn post published and URL submitted
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