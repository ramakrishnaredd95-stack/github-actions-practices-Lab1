# Terraform Infrastructure for FlipkartMobilePage

This directory contains Terraform configuration to provision Azure infrastructure for the FlipkartMobilePage application.

## Resources Created

- **Resource Group**: Container for all Azure resources
- **Azure Container Registry (ACR)**: Private Docker registry for container images
- **Azure Kubernetes Service (AKS)**: Managed Kubernetes cluster
- **Role Assignment**: Allows AKS to pull images from ACR

## Prerequisites

1. **Azure CLI** installed and authenticated

   ```bash
   az login
   ```

2. **Terraform** installed (version >= 1.0)

   ```bash
   terraform --version
   ```

3. **Azure Subscription**: Update `subscription_id` in `terraform.tfvars`

## Usage

### Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads the Azure provider and initializes the backend.

### Plan Infrastructure

```bash
terraform plan
```

Review the planned changes before applying.

### Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This will create:

- Resource group
- ACR (takes ~1-2 minutes)
- AKS cluster (takes ~5-10 minutes)

### View Outputs

```bash
terraform output
```

To view sensitive outputs:

```bash
terraform output acr_admin_password
terraform output aks_kube_config
```

### Get AKS Credentials

```bash
az aks get-credentials --resource-group rg-flipkart-app --name aks-flipkart-cluster
```

Or use the output command:

```bash
terraform output -raw get_credentials_command | bash
```

### Verify Resources

**Check ACR:**

```bash
az acr list --resource-group rg-flipkart-app --output table
```

**Check AKS:**

```bash
az aks list --resource-group rg-flipkart-app --output table
kubectl get nodes
```

## Customization

Edit `terraform.tfvars` to customize:

- `resource_group_name`: Name of the resource group
- `location`: Azure region (e.g., "East US", "West Europe")
- `acr_name`: ACR name (must be globally unique)
- `acr_sku`: ACR tier (Basic, Standard, Premium)
- `aks_cluster_name`: AKS cluster name
- `aks_node_count`: Number of nodes (default: 1)
- `aks_node_vm_size`: VM size for nodes
- `kubernetes_version`: Kubernetes version

## Destroy Infrastructure

⚠️ **Warning**: This will delete all resources and data.

```bash
terraform destroy
```

Type `yes` when prompted.

## Cost Considerations

- **ACR Basic**: ~$5/month
- **AKS**: ~$73/month per node (Standard_DS2_v2)
- **Load Balancer**: ~$18/month

Total estimated cost: ~$96/month for development environment.

## Troubleshooting

### ACR Name Already Exists

If the ACR name is taken, change `acr_name` in `terraform.tfvars` to a unique value.

### AKS Creation Timeout

AKS creation can take 10-15 minutes. If it times out, run `terraform apply` again.

### Permission Errors

Ensure your Azure account has Contributor role on the subscription.
