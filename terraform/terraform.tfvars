# Azure Subscription ID - REPLACE WITH YOUR SUBSCRIPTION ID
subscription_id = "16d60876-2016-4013-9895-cc00224e539c"

# Resource Group Configuration
resource_group_name = "rg-flipkart-app11132212"
location            = "canadacentral"

# Azure Container Registry Configuration
acr_name = "acrflipkartmobile22532533"
acr_sku  = "Basic"

# Azure Kubernetes Service Configuration
aks_cluster_name   = "aks-flipkart-cluster22325342"
aks_node_count     = 2
aks_node_vm_size   = "Standard_B2s"
kubernetes_version = "1.30.14"

# Azure Storage Account Configuration
storage_account_name             = "stflipkartapp11132212"
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"

# Environment and Tags
environment = "dev"

tags = {
  Project   = "FlipkartMobilePage"
  ManagedBy = "Terraform"
  Owner     = "DevOps Team"
}

# ============================================================================
# Security Configuration
# ============================================================================

# ACR Security Settings
# Note: admin_enabled will be automatically set based on environment if not specified
# acr_admin_enabled = false  # Uncomment to override environment-based setting

# Network Access Control
acr_public_access_enabled = true # Set to false for production to restrict access
acr_allowed_ip_ranges     = []   # Add your IP ranges in CIDR notation, e.g., ["203.0.113.0/24"]
acr_allowed_subnet_ids    = []   # Add subnet IDs if using VNet integration

# Diagnostic Settings
enable_acr_diagnostics = true
acr_retention_days     = 30

# Key Vault Configuration
enable_key_vault              = true
key_vault_name                = "kvflipkartapp11132212"
key_vault_sku                 = "standard"
kv_soft_delete_retention_days = 7
kv_purge_protection_enabled   = false # Set to true for production

# CI/CD Configuration
enable_cicd_access          = false
cicd_service_principal_id   = "" # Add your GitHub Actions or Azure DevOps service principal object ID
cicd_service_principal_name = "GitHub-Actions-SP"

# Monitoring Configuration
enable_log_analytics         = true
log_analytics_workspace_name = "log-flipkart-dev"
log_analytics_retention_days = 30

