variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  # default     = "rg-flipkart-app"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  # default     = "East US"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
# default     = "acrflipkartmobile"
}

variable "acr_sku" {
  description = "SKU tier for ACR"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  description = "Enable admin account for ACR (not recommended for production)"
  type        = bool
  default     = null # Will be set based on environment if null
}

variable "acr_public_access_enabled" {
  description = "Enable public network access to ACR"
  type        = bool
  default     = false
}

variable "acr_allowed_ip_ranges" {
  description = "List of allowed IP ranges for ACR access (CIDR notation)"
  type        = list(string)
  default     = []
}

variable "acr_allowed_subnet_ids" {
  description = "List of allowed subnet IDs for ACR access"
  type        = list(string)
  default     = []
}

variable "enable_acr_diagnostics" {
  description = "Enable diagnostic settings for ACR"
  type        = bool
  default     = true
}

variable "acr_retention_days" {
  description = "Number of days to retain ACR diagnostic logs"
  type        = number
  default     = 30
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  # default     = "aks-flipkart-cluster"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "aks_node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.29"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account (must be globally unique, 3-24 lowercase letters and numbers)"
  type        = string
  # default     = "stflipkartmobile"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Invalid replication type."
  }
}

variable "environment" {
  description = "Environment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Key Vault Configuration
variable "enable_key_vault" {
  description = "Enable Azure Key Vault for credential management"
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique)"
  type        = string
  # default     = "kv-flipkart-app"
}

variable "key_vault_sku" {
  description = "SKU for Azure Key Vault"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be standard or premium."
  }
}

variable "kv_soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vault items"
  type        = number
  default     = 7
}

variable "kv_purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

# CI/CD Configuration
variable "enable_cicd_access" {
  description = "Enable CI/CD service principal access to ACR"
  type        = bool
  default     = false
}

variable "cicd_service_principal_id" {
  description = "Object ID of the CI/CD service principal for ACR push access"
  type        = string
  default     = ""
}

variable "cicd_service_principal_name" {
  description = "Display name of the CI/CD service principal"
  type        = string
  default     = "GitHub-Actions-SP"
}

# Monitoring Configuration
variable "enable_log_analytics" {
  description = "Enable Log Analytics workspace for monitoring"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "log-flipkart-app"
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "FlipkartMobilePage"
    ManagedBy = "Terraform"
  }
}
