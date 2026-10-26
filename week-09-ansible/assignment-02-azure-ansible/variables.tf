
variable "subscription_id" {
  description = "Azure subscription used for the assignment"
  type        = string
}

variable "location" {
  description = "Azure region for the assignment resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for the four Azure VMs"
  type        = string
  default     = "rg-dmi-ansible-week09"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux administrator username"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the existing SSH public key"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your public IP in CIDR format for SSH access"
  type        = string
}

variable "vm_names" {
  description = "Names of the four assignment virtual machines"
  type        = list(string)
  default     = ["web1", "web2", "app1", "db1"]
}
