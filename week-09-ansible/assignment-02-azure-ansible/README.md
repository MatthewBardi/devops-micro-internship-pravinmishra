# Assignment 02 — Azure Terraform and Ansible Ad-Hoc Automation

## Project Overview

This project is part of Week 09 of the DevOps Micro Internship (DMI) Cohort 3.

The objective is to provision four Ubuntu 22.04 virtual machines in Microsoft Azure using Terraform, configure passwordless SSH authentication, organize the machines into Ansible inventory groups, and perform administrative tasks using Ansible ad-hoc commands.

## Infrastructure Architecture

| Virtual Machine | Role | Private IP | VM Size |
|---|---|---|---|
| web1 | Web server | 10.10.1.10 | Standard_B1s |
| web2 | Web server | 10.10.1.11 | Standard_B1s |
| app1 | Application server | 10.10.1.12 | Standard_B1s |
| db1 | Database server | 10.10.1.13 | Standard_B1s |

All four VMs are configured to use Ubuntu Server 22.04 LTS, with Azure-assigned public IP addresses.

## Tools

- Terraform and AzureRM provider
- Azure CLI
- Ansible in Ubuntu WSL
- Visual Studio Code
- Git and GitHub
- SSH Ed25519 key authentication

## Project Files

| File | Purpose |
|---|---|
| `providers.tf` | Terraform and AzureRM provider configuration |
| `variables.tf` | Deployment variables |
| `main.tf` | Azure infrastructure resources |
| `outputs.tf` | VM names, public IPs, and private IPs |
| `terraform.tfvars.example` | Example deployment variables |
| `inventory.ini.example` | Example Ansible inventory |
| `ansible-commands.md` | Reference for required ad-hoc commands |
| `.gitignore` | Prevents sensitive and temporary files from entering Git |
| `.terraform.lock.hcl` | Records provider dependency versions |

## Terraform Setup

From the project directory, run:

```powershell
terraform init -backend=false
terraform fmt
terraform validate
```

Before deployment, copy `terraform.tfvars.example` to `terraform.tfvars` and replace the example values with an authorized, active Azure subscription, the correct SSH public key path, and the administrator's public IP address.

After reviewing the configuration, use:

```powershell
terraform plan
terraform apply
terraform output public_ips
```

## Ansible Configuration

After provisioning, replace the placeholder addresses in `inventory.ini.example` and save the completed configuration as `inventory.ini`.

Use Ansible from Ubuntu WSL with the corresponding SSH private key.

See `ansible-commands.md` for the required connectivity, system information, Nginx, and htop commands.

## Security Considerations

- SSH password authentication is disabled.
- SSH access is restricted to the administrator's allowed public IP range.
- HTTP access is limited to the two web server private addresses.
- Terraform state, local variable files, and SSH private keys must not be committed.
- SSH host keys should be verified before first connection.

## Deployment Status

**Infrastructure configuration prepared and Terraform validation successful.**

Azure resources have not yet been provisioned because the available Azure subscription is disabled following expiration of its free trial.

Therefore, live SSH verification, Ansible execution, and the required deployment screenshots remain pending.

## Cleanup

After completing the hands-on activities and capturing evidence, destroy the Terraform-managed infrastructure:

```powershell
terraform destroy
```

Verify in the Azure portal that the assignment resource group and its resources have been removed.

## Lessons Learned

This project demonstrates how Terraform can define repeatable cloud infrastructure and how Ansible can manage multiple remote Linux systems through a structured inventory.

Using version-controlled configuration, SSH key authentication, restricted network access, and reproducible tooling supports safer infrastructure automation.
