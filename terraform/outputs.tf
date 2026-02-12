output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "ACR name"
  value       = azurerm_container_registry.acr.name
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_kube_config" {
  description = "Kubernetes configuration for AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "get_credentials_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.storage.primary_connection_string
  sensitive   = true
}

# ============================================================================
# Security Outputs
# ============================================================================

output "acr_login_server_security" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_enabled" {
  description = "Whether ACR admin account is enabled"
  value       = azurerm_container_registry.acr.admin_enabled
}

output "acr_admin_username_security" {
  description = "ACR admin username (only if admin is enabled)"
  value       = azurerm_container_registry.acr.admin_enabled ? azurerm_container_registry.acr.admin_username : null
  sensitive   = true
}

output "acr_identity_principal_id" {
  description = "Principal ID of the ACR managed identity"
  value       = azurerm_container_registry.acr.identity[0].principal_id
}

output "key_vault_id" {
  description = "ID of the Azure Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].id : null
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].vault_uri : null
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault"
  value       = var.enable_key_vault ? azurerm_key_vault.main[0].name : null
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.enable_log_analytics ? azurerm_log_analytics_workspace.main[0].id : null
}

output "aks_kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "security_summary" {
  description = "Summary of security configuration"
  value = {
    acr_admin_enabled         = azurerm_container_registry.acr.admin_enabled
    acr_public_access_enabled = var.acr_public_access_enabled
    key_vault_enabled         = var.enable_key_vault
    monitoring_enabled        = var.enable_log_analytics
    cicd_access_enabled       = var.enable_cicd_access
    environment               = var.environment
  }
}

output "storage_account_primary_access_key" {
  description = "Storage account primary access key"
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

output "storage_containers" {
  description = "Storage container names"
  value = {
    app_data             = azurerm_storage_container.app_data.name
    deployment_artifacts = azurerm_storage_container.deployment_artifacts.name
  }
}
