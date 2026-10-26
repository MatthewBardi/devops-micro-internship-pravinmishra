
# Resource group for Assignment 02
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Project     = "DMI-Week09-Ansible"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}

# Virtual network for the four Azure VMs
resource "azurerm_virtual_network" "main" {
  name                = "vnet-dmi-ansible-week09"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet for the four VMs
resource "azurerm_subnet" "main" {
  name                 = "snet-dmi-ansible-week09"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.1.0/24"]
}


# Network Security Group for Assignment 02
resource "azurerm_network_security_group" "main" {
  name                = "nsg-dmi-ansible-week09"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Project   = "DMI-Week09-Ansible"
    ManagedBy = "Terraform"
  }
}

# Allow SSH only from the administrator's public IP
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH-From-My-IP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.allowed_ssh_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Allow HTTP traffic for the Nginx web servers
resource "azurerm_network_security_rule" "http" {
  name                   = "Allow-HTTP"
  priority               = 110
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "80"
  source_address_prefix  = "*"
  destination_address_prefixes = [
    "10.10.1.10",
    "10.10.1.11"
  ]
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Associate the NSG with the assignment subnet
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}


# Create a public IP address for each virtual machine
resource "azurerm_public_ip" "vm" {
  count = length(var.vm_names)

  name                = "pip-${var.vm_names[count.index]}-dmi"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    Project   = "DMI-Week09-Ansible"
    ManagedBy = "Terraform"
  }
}


# Network interface for each virtual machine
resource "azurerm_network_interface" "vm" {
  count = length(var.vm_names)

  name                = "nic-${var.vm_names[count.index]}-dmi"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost("10.10.1.0/24", count.index + 10)
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }

  tags = {
    Project   = "DMI-Week09-Ansible"
    ManagedBy = "Terraform"
  }
}


# Create four Ubuntu 22.04 virtual machines
resource "azurerm_linux_virtual_machine" "vm" {
  count = length(var.vm_names)

  name                = var.vm_names[count.index]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Project     = "DMI-Week09-Ansible"
    Environment = "Learning"
    ManagedBy   = "Terraform"
  }
}
