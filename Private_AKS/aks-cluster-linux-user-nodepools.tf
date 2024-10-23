# # Create Linux Azure AKS Node Pool
# resource "azurerm_kubernetes_cluster_node_pool" "linux101" {
#   zones                 = [1, 2, 3]  # Availability zones
#   enable_auto_scaling   = true
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id  # Corrected reference
#   max_count             = 1
#   min_count             = 1
#   mode                  = "User"
#   name                  = "linux101"
#   orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
#   os_disk_size_gb       = 30
#   os_type               = "Linux"  # Default is Linux; can change to Windows
#   vm_size               = "Standard_DS2_v2"
#   priority              = "Regular"  # Default is Regular; can change to Spot
#   vnet_subnet_id        = azurerm_subnet.aks_subnet.id  # Ensure you use the correct subnet

#   node_labels = {
#     "nodepool-type" = "user"
#     "environment"   = var.environment
#     "nodepoolos"    = "linux"
#     "app"           = "facebook-apps"
#   }

#   tags = {
#     "nodepool-type" = "user"
#     "environment"   = var.environment
#     "nodepoolos"    = "linux"
#     "app"           = "facebook-apps"
#   }
# }
