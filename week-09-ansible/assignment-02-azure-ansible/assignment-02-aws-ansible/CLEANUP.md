
# Week 09 AWS Ansible — Cleanup Checklist

## Before cleanup
- Confirm assignment screenshots and evidence are saved.
- Confirm no important data is needed from the four servers.
- Open PowerShell in the assignment-02-aws-ansible directory.
- Authenticate using the dmi-terraform-operator AWS profile.

## Verify AWS identity
aws sts get-caller-identity --profile dmi-terraform-operator

## Select the AWS profile (PowerShell)
$env:AWS_PROFILE = "dmi-terraform-operator"

## Review resources before deletion
terraform plan -destroy

## Delete assignment infrastructure
terraform destroy

## Verify Terraform state is empty
terraform state list

## Verify no Week 09 EC2 instances remain
aws ec2 describe-instances --region us-east-1 --profile dmi-terraform-operator --filters "Name=tag:Project,Values=DMI-Week09-Ansible" --query "Reservations[].Instances[].{ID:InstanceId,State:State.Name}" --output table

## Additional AWS Console checks
- EC2 Instances: no Week 09 running or stopped instances.
- EBS Volumes: no leftover Week 09 volumes.
- EC2 Snapshots and AMIs: no unexpected retained backups.
- Elastic IPs: no unused allocated addresses.
- VPC: no leftover Week 09 VPC or networking resources.
- Billing: review ongoing usage and charges.

## Important
- Do not delete local Terraform state before cleanup.
- Do not run terraform apply again after cleanup.
- Terraform destroy permanently deletes the managed environment.
- AWS billing information may take time to update.
