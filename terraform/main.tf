# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# Azure Container Registry with Enhanced Security
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku

  # Conditional admin account: enabled only in dev environment
  admin_enabled = var.acr_admin_enabled != null ? var.acr_admin_enabled : (var.environment == "dev" ? true : false)

  # Enable managed identity for secure authentication
  identity {
    type = "SystemAssigned"
  }

  # Network security configuration
  public_network_access_enabled = var.acr_public_access_enabled

  # Network rules (only if public access is enabled and restrictions are defined)
  dynamic "network_rule_set" {
    for_each = var.acr_public_access_enabled && (length(var.acr_allowed_ip_ranges) > 0 || length(var.acr_allowed_subnet_ids) > 0) ? [1] : []
    content {
      default_action = "Deny"

      # IP-based access rules
      dynamic "ip_rule" {
        for_each = var.acr_allowed_ip_ranges
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }
    }
  }


  tags = merge(
    var.tags,
    {
      Environment   = var.environment
      SecurityLevel = var.environment == "dev" ? "Development" : "Production"
      AdminEnabled  = var.acr_admin_enabled != null ? var.acr_admin_enabled : (var.environment == "dev" ? true : false)
    }
  )
}

# Azure Kubernetes Service
# Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  # REQUIRED for LTS versions
  sku_tier     = "Premium"              # Adds cost!
  support_plan = "AKSLongTermSupport" 

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}


# Role Assignment: Allow AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Role Assignment: Allow CI/CD pipeline to push images to ACR
resource "azurerm_role_assignment" "cicd_acr_push" {
  count                            = var.enable_cicd_access && var.cicd_service_principal_id != "" ? 1 : 0
  principal_id                     = var.cicd_service_principal_id
  role_definition_name             = "AcrPush"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# Azure Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type

  # Enable features (updated for azurerm v4)
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# Storage Container for application data
resource "azurerm_storage_container" "app_data" {
  name                  = "app-data"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

# Storage Container for deployment artifacts
resource "azurerm_storage_container" "deployment_artifacts" {
  name                  = "deployment-artifacts"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}
