
variable "aws_region" {
  description = "AWS region for the training environment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the Ubuntu servers"
  type        = string
  default     = "t3.micro"
}

variable "vm_names" {
  description = "Names of the four Ubuntu servers"
  type        = list(string)
  default     = ["web1", "web2", "app1", "db1"]
}

variable "public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "~/.ssh/week09-aws-ansible.pub"
}

variable "ssh_allowed_cidr" {
  description = "Public IP address allowed to connect over SSH"
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 8
}
