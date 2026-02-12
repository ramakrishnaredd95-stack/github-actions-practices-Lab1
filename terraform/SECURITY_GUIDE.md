# Enhanced ACR Security Implementation - Complete Guide

## Overview

This implementation provides comprehensive security enhancements for Azure Container Registry (ACR) with managed identity authentication, network restrictions, credential management via Azure Key Vault, and monitoring capabilities.

## 🔐 Key Security Features Implemented

### 1. **Conditional Admin Account**

- **Environment-Based Control**: Admin account is automatically enabled in `dev` and disabled in `prod`
- **Override Capability**: Can be explicitly controlled via `acr_admin_enabled` variable
- **Secure Storage**: Admin credentials automatically stored in Azure Key Vault when enabled

### 2. **Managed Identity Authentication**

- **System-Assigned Identity**: ACR has a managed identity for secure authentication
- **RBAC Integration**: AKS uses `AcrPull` role to pull images without credentials
- **CI/CD Support**: Optional service principal with `AcrPush` role for pipelines

### 3. **Network Security**

- **Public Access Control**: Configurable via `acr_public_access_enabled`
- **IP Restrictions**: Support for IP-based access rules (CIDR notation)
- **Default Deny**: Network rules default to deny with explicit allow rules

### 4. **Azure Key Vault Integration**

- **Credential Management**: Secure storage of ACR admin credentials
- **Access Policies**: Controlled access for AKS, CI/CD, and Terraform
- **Soft Delete**: 7-day retention for deleted secrets
- **Audit Logging**: All Key Vault operations are logged

### 5. **Monitoring & Diagnostics**

- **Log Analytics**: Centralized logging for ACR and Key Vault
- **Diagnostic Settings**: Container registry events, login events, and metrics
- **Retention Policies**: 30-day log retention (configurable)

## 📁 Files Modified/Created

| File               | Status      | Description                                                          |
| ------------------ | ----------- | -------------------------------------------------------------------- |
| `variables.tf`     | ✅ Modified | Added 20+ security-related variables                                 |
| `main.tf`          | ✅ Modified | Enhanced ACR with conditional admin, managed identity, network rules |
| `security.tf`      | ✅ Created  | Key Vault, Log Analytics, diagnostic settings, access policies       |
| `terraform.tfvars` | ✅ Modified | Security configuration values                                        |
| `outputs.tf`       | ✅ Modified | Security outputs including Key Vault URI, ACR login server           |
| `provider.tf`      | ✅ Existing | Azure provider configuration (no changes needed)                     |

## 🚀 Quick Start

### Step 1: Review Configuration

Open `terraform.tfvars` and configure security settings:

```hcl
# ACR Security Settings
acr_public_access_enabled = true  # Set to false for production
acr_allowed_ip_ranges     = []    # Add your IP ranges

# Key Vault Configuration
enable_key_vault = true
key_vault_name   = "kv-flipkart-dev"  # Must be globally unique

# Monitoring
enable_log_analytics = true
```

### Step 2: Initialize and Validate

```bash
terraform init
terraform validate
terraform fmt
```

### Step 3: Plan and Apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 4: Retrieve Outputs

```bash
# Get ACR login server
terraform output acr_login_server

# Get security summary
terraform output security_summary

# Get Key Vault URI (sensitive)
terraform output key_vault_uri
```

## 🔧 Configuration Options

### Admin Account Control

**Option 1: Environment-Based (Recommended)**

```hcl
# In terraform.tfvars - leave acr_admin_enabled commented out
# Admin will be enabled in dev, disabled in prod
environment = "dev"
```

**Option 2: Explicit Override**

```hcl
# In terraform.tfvars - explicitly control admin account
acr_admin_enabled = false  # Force disable even in dev
```

### Network Access Control

**Development (Open Access)**

```hcl
acr_public_access_enabled = true
acr_allowed_ip_ranges     = []
```

**Production (Restricted Access)**

```hcl
acr_public_access_enabled = true
acr_allowed_ip_ranges     = [
  "203.0.113.0/24",      # Office network
  "198.51.100.50/32"     # CI/CD server
]
```

**Maximum Security (Private Only)**

```hcl
acr_public_access_enabled = false
# Use private endpoints (requires Premium SKU)
```

### CI/CD Integration

**Enable GitHub Actions/Azure DevOps Access**

```hcl
enable_cicd_access        = true
cicd_service_principal_id = "your-sp-object-id"
```

To get your service principal object ID:

```bash
az ad sp list --display-name "GitHub-Actions-SP" --query "[0].id" -o tsv
```

## 🔑 Using ACR with Different Authentication Methods

### Method 1: Managed Identity (Recommended)

```bash
# AKS automatically uses managed identity - no configuration needed
# Images are pulled using the AcrPull role assignment
```

### Method 2: Admin Credentials (Dev Only)

```bash
# Retrieve from Key Vault
az keyvault secret show --vault-name kv-flipkart-dev --name acr-admin-username --query value -o tsv
az keyvault secret show --vault-name kv-flipkart-dev --name acr-admin-password --query value -o tsv

# Or use Terraform output
terraform output acr_admin_username
```

### Method 3: Service Principal (CI/CD)

```bash
# CI/CD pipeline uses service principal with AcrPush role
# Configured via enable_cicd_access variable
```

## 📊 Monitoring and Auditing

### View ACR Logs

```bash
# Query Log Analytics for container registry events
az monitor log-analytics query \
  --workspace "log-flipkart-dev" \
  --analytics-query "ContainerRegistryRepositoryEvents | take 10"
```

### View Key Vault Audit Logs

```bash
# Query Key Vault access logs
az monitor log-analytics query \
  --workspace "log-flipkart-dev" \
  --analytics-query "AzureDiagnostics | where ResourceType == 'VAULTS' | take 10"
```

## 🛡️ Security Best Practices

### ✅ Implemented

- [x] Managed identity for ACR authentication
- [x] RBAC role assignments (AcrPull, AcrPush)
- [x] Conditional admin account (dev only)
- [x] Secure credential storage in Key Vault
- [x] Network access restrictions
- [x] Comprehensive audit logging
- [x] Diagnostic settings for monitoring

### 🔄 Recommended Next Steps

- [ ] Upgrade to Premium SKU for advanced features
- [ ] Implement private endpoints for ACR
- [ ] Enable Azure Defender for container registries
- [ ] Configure image vulnerability scanning
- [ ] Set up automated credential rotation
- [ ] Implement network policies in AKS

## 🔍 Troubleshooting

### Issue: Cannot access ACR

**Solution**: Check network rules and public access settings

```bash
terraform output security_summary
# Verify acr_public_access_enabled is true
# Check acr_allowed_ip_ranges includes your IP
```

### Issue: AKS cannot pull images

**Solution**: Verify role assignment

```bash
# Check AKS managed identity has AcrPull role
az role assignment list --scope $(terraform output -raw acr_id) --query "[?roleDefinitionName=='AcrPull']"
```

### Issue: Key Vault access denied

**Solution**: Check access policies

```bash
# Verify your identity has access
az keyvault show --name kv-flipkart-dev --query properties.accessPolicies
```

## 📝 Variable Reference

### Security Variables

| Variable                    | Type         | Default | Description                                       |
| --------------------------- | ------------ | ------- | ------------------------------------------------- |
| `acr_admin_enabled`         | bool         | null    | Override admin account (null = environment-based) |
| `acr_public_access_enabled` | bool         | false   | Enable public network access                      |
| `acr_allowed_ip_ranges`     | list(string) | []      | Allowed IP ranges (CIDR)                          |
| `enable_key_vault`          | bool         | true    | Enable Key Vault for credentials                  |
| `enable_log_analytics`      | bool         | true    | Enable monitoring                                 |
| `enable_cicd_access`        | bool         | false   | Enable CI/CD service principal                    |

### Output Variables

| Output              | Description                     |
| ------------------- | ------------------------------- |
| `acr_login_server`  | ACR login URL                   |
| `acr_admin_enabled` | Admin account status            |
| `key_vault_uri`     | Key Vault URI                   |
| `security_summary`  | Complete security configuration |

## 🎯 Environment-Specific Configurations

### Development Environment

```hcl
environment                   = "dev"
acr_public_access_enabled    = true
key_vault_name               = "kv-flipkart-dev"
kv_purge_protection_enabled  = false
```

### Production Environment

```hcl
environment                   = "prod"
acr_admin_enabled            = false  # Explicitly disable
acr_public_access_enabled    = false  # Use private endpoints
acr_sku                      = "Premium"
key_vault_name               = "kv-flipkart-prod"
kv_purge_protection_enabled  = true
```

## 📚 Additional Resources

- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)
- [Azure Key Vault Best Practices](https://docs.microsoft.com/azure/key-vault/general/best-practices)
- [AKS and ACR Integration](https://docs.microsoft.com/azure/aks/cluster-container-registry-integration)
- [Azure RBAC Documentation](https://docs.microsoft.com/azure/role-based-access-control/)

---

**Implementation Date**: 2026-02-12  
**Terraform Version**: >= 1.0  
**Azure Provider Version**: ~> 4.0
