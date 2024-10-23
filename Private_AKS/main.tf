terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Provider Configuration
# provider "azurerm" {
#   features {}
# }

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}



# Random Pet Name
resource "random_pet" "unique_name" {
  length = 2
}

# Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
}

# # Storage Account for Terraform State
# resource "azurerm_storage_account" "tfstate" {
#   name                     = "${lower(var.resource_group_name)}${lower(var.environment)}tfstate"
#   resource_group_name      = azurerm_resource_group.aks_rg.name
#   location                 = azurerm_resource_group.aks_rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# # Storage Container for TFState
# resource "azurerm_storage_container" "tfstate" {
#   name                  = "tfstate"
#   storage_account_name  = azurerm_storage_account.tfstate.name
#   container_access_type = "private"
# }

# Virtual Network
resource "azurerm_virtual_network" "aksvnet" {
  name                = "${var.resource_group_name}-${var.environment}-vnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/8"]
}

# Subnets
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.resource_group_name}-${var.environment}-aks-subnet"
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "${var.resource_group_name}-${var.environment}-bastion-subnet"
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  address_prefixes     = ["10.241.0.0/24"]
}

# Network Security Groups
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.resource_group_name}-${var.environment}-aks-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "allow-bastion-access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.bastion_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${var.resource_group_name}-${var.environment}-bastion-nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

# Public IP for Bastion Host
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "${var.resource_group_name}-${var.environment}-bastion-pip"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface for Bastion Host
resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.resource_group_name}-${var.environment}-bastion-nic"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_public_ip.id
  }
}

# Azure Bastion Host
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "${var.resource_group_name}-${var.environment}-bastion"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  size                = var.bastion_vm_size
  admin_username      = "azureuser"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.bastion_public_ip.ip_address
      user        = "azureuser"
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl",
      "sudo chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3",
      "chmod 700 get_helm.sh",
      "./get_helm.sh",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    ]
  }

  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = var.environment
  }

    admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key)
  }
}



# Azure Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "${var.resource_group_name}-${var.environment}-law"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"

  default_node_pool {
    name                 = "systempool"
    vm_size              = var.default_node_size  # e.g., "Standard_DS2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    zones                = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = var.max_node_count      # e.g., 3
    min_count            = var.min_node_count       # e.g., 1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id  # Updated reference
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = var.environment  # Corrected variable reference
      "nodepoolos"       = "linux"
      "app"              = "system-apps"
    }
    tags = {
      "nodepool-type"    = "system"
      "environment"      = var.environment  # Corrected variable reference
      "nodepoolos"       = "linux"
      "app"              = "system-apps"
    }
  }

  # Identity (System Assigned)
  identity {
    type = "SystemAssigned"
  }

  # OMS Agent
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
  }

  # # Azure Active Directory RBAC
  # azure_active_directory_role_based_access_control {
  #   managed                = true
  #   admin_group_object_ids = [azuread_group.aks_administrators.id]
  # }

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  # Network Profile
  network_profile {
    network_plugin   = "azure"
    load_balancer_sku = "standard"
  }

  private_cluster_enabled = true

  tags = {
    environment = var.environment
  }
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = lower(var.acr_name)
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = var.acr_sku
  admin_enabled       = true
}

# Assign ACR Pull Permission to AKS
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

# Outputs
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}



