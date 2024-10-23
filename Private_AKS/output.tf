output "location" {
  value = azurerm_resource_group.aks_rg.location
}



output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}




output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.aks_rg.name
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_cluster.name
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

# Azure AKS Versions Datasource
output "versions" {
  value = data.azurerm_kubernetes_service_versions.current.versions
}

output "latest_version" {
  value = data.azurerm_kubernetes_service_versions.current.latest_version
}

# Azure AD Group Object Id
output "azure_ad_group_id" {
  value = azuread_group.aks_administrators.id
}
output "azure_ad_group_objectid" {
  value = azuread_group.aks_administrators.object_id
}


output "aks_cluster_kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}



# Output for Bastion Host Public IP
output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = azurerm_public_ip.bastion_public_ip.ip_address
}


# Outputs for Storage Account and Storage Container
output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  value = azurerm_storage_account.tfstate.id
}

output "storage_container_name" {
  value = azurerm_storage_container.tfstate.name
}

output "storage_container_id" {
  value = azurerm_storage_container.tfstate.id
}

output "storage_container_access_type" {
  value = azurerm_storage_container.tfstate.container_access_type
}
