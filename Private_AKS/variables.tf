variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
}

variable "default_node_count" {
  description = "The default number of nodes in the AKS cluster"
  type        = number
  default     = 3
}

variable "default_node_size" {
  description = "The size of the virtual machines for the AKS cluster"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "min_node_count" {
  description = "Minimum number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the AKS cluster"
  type        = number
  default     = 5
}

variable "ssh_public_key" {
  description = "Path to the SSH public key for AKS"
  type        = string
}

variable "ssh_private_key" {
  description = "Path to the SSH private key for AKS"
  type        = string
}

variable "bastion_vm_size" {
  description = "The size of the virtual machines for the bastion host"
  type        = string
  default     = "Standard_B2s"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry (ACR)"
  type        = string
}

variable "acr_sku" {
  description = "The SKU for the Azure Container Registry"
  type        = string
  default     = "Basic"
}
