# ============================================================================
# Security Resources: Key Vault, Monitoring, and Credential Management
# ============================================================================

# Log Analytics Workspace for Monitoring
resource "azurerm_log_analytics_workspace" "main" {
  count               = var.enable_log_analytics ? 1 : 0
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Purpose     = "Monitoring"
    }
  )
}

# Azure Key Vault for Credential Management
resource "azurerm_key_vault" "main" {
  count                      = var.enable_key_vault ? 1 : 0
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  purge_protection_enabled   = var.kv_purge_protection_enabled

  # Network security
  public_network_access_enabled = var.acr_public_access_enabled

  # Access policy for current Terraform service principal/user
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Create",
      "Delete"
    ]

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete"
    ]
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Purpose     = "Credential Management"
    }
  )
}

# Access Policy: Allow AKS to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "aks" {
  count        = var.enable_key_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.main[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Access Policy: Allow CI/CD service principal to read secrets
resource "azurerm_key_vault_access_policy" "cicd" {
  count        = var.enable_key_vault && var.enable_cicd_access && var.cicd_service_principal_id != "" ? 1 : 0
  key_vault_id = azurerm_key_vault.main[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.cicd_service_principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Store ACR admin username in Key Vault (only if admin is enabled)
resource "azurerm_key_vault_secret" "acr_admin_username" {
  count        = var.enable_key_vault && (var.acr_admin_enabled != null ? var.acr_admin_enabled : (var.environment == "dev" ? true : false)) ? 1 : 0
  name         = "acr-admin-username"
  value        = azurerm_container_registry.acr.admin_username
  key_vault_id = azurerm_key_vault.main[0].id

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Resource    = "ACR"
    }
  )

  depends_on = [
    azurerm_key_vault_access_policy.aks
  ]
}

# Store ACR admin password in Key Vault (only if admin is enabled)
resource "azurerm_key_vault_secret" "acr_admin_password" {
  count        = var.enable_key_vault && (var.acr_admin_enabled != null ? var.acr_admin_enabled : (var.environment == "dev" ? true : false)) ? 1 : 0
  name         = "acr-admin-password"
  value        = azurerm_container_registry.acr.admin_password
  key_vault_id = azurerm_key_vault.main[0].id

  tags = merge(
    var.tags,
    {
      Environment = var.environment
      Resource    = "ACR"
      Sensitive   = "true"
    }
  )

  depends_on = [
    azurerm_key_vault_access_policy.aks
  ]
}

# Diagnostic Settings for ACR
resource "azurerm_monitor_diagnostic_setting" "acr" {
  count                      = var.enable_acr_diagnostics && var.enable_log_analytics ? 1 : 0
  name                       = "acr-diagnostics"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  # Enable all log categories
  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  # Enable all metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count                      = var.enable_key_vault && var.enable_log_analytics ? 1 : 0
  name                       = "keyvault-diagnostics"
  target_resource_id         = azurerm_key_vault.main[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main[0].id

  # Enable audit logs
  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  # Enable all metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}
