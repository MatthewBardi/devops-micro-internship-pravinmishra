
# Public IP addresses for SSH and Ansible
output "public_server_ips" {
  description = "Public IP addresses of web1, web2, and app1"

  value = {
    for name, instance in aws_instance.public_servers :
    name => instance.public_ip
  }
}

# Private IP addresses of public servers
output "public_server_private_ips" {
  description = "Private IP addresses of public servers"

  value = {
    for name, instance in aws_instance.public_servers :
    name => instance.private_ip
  }
}

# Private database IP address
output "database_private_ip" {
  description = "Private IP address of db1"
  value       = aws_instance.database.private_ip
}

# EC2 instance IDs
output "instance_ids" {
  description = "EC2 instance IDs for all four servers"

  value = merge(
    {
      for name, instance in aws_instance.public_servers :
      name => instance.id
    },
    {
      db1 = aws_instance.database.id
    }
  )
}

# SSH jump host address
output "ssh_jump_host" {
  description = "Public IP address of web1 for accessing db1"
  value       = aws_instance.public_servers["web1"].public_ip
}
