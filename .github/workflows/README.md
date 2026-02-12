# GitHub Actions CI/CD Pipeline

This directory contains the GitHub Actions workflow for the FlipkartMobilePage application.

## Workflow: CI/CD Pipeline

**File**: `dotnet-build-test.yml`

**Pipeline Stages**: Push → CI Build → Docker Build → Push to ACR → Deploy to AKS

## Workflow Overview

### Triggers

- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual trigger via `workflow_dispatch`

### Jobs

#### 1. Build and Test (.NET)

- Checkout code
- Setup .NET 10.0
- Restore dependencies
- Build solution
- Run tests
- Publish test results

#### 2. Docker Build and Push to ACR

- Generate image tag (short SHA)
- Login to Azure
- Login to ACR
- Build Docker image
- Tag image with SHA and 'latest'
- Push to ACR
- Verify image in registry

**Runs only on**: Push to `main` or `develop`

#### 3. Deploy to AKS

- Login to Azure
- Get AKS credentials
- Update deployment manifest with new image tag
- Apply Kubernetes manifests
- Wait for rollout completion
- Display deployment status
- Get application endpoint

**Runs only on**: Push to `main` branch

## Required GitHub Secrets

### AZURE_CREDENTIALS

Azure Service Principal credentials in JSON format.

**Create Service Principal:**

```bash
az ad sp create-for-rbac \
  --name "github-actions-flipkart" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-flipkart-app \
  --sdk-auth
```

**Output format:**

```json
{
  "clientId": "<client-id>",
  "clientSecret": "<client-secret>",
  "subscriptionId": "<subscription-id>",
  "tenantId": "<tenant-id>",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

**Add to GitHub:**

1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `AZURE_CREDENTIALS`
4. Value: Paste the entire JSON output
5. Click "Add secret"

## Environment Variables

The workflow uses these environment variables (configured in the workflow file):

- `AZURE_RESOURCE_GROUP`: rg-flipkart-app
- `ACR_NAME`: acrflipkartmobile
- `AKS_CLUSTER_NAME`: aks-flipkart-cluster
- `IMAGE_NAME`: flipkartmobilepage

**Note**: Update these if you changed the Terraform variable values.

## Manual Workflow Trigger

1. Go to repository → Actions tab
2. Select "CI/CD Pipeline - Build, Push to ACR, Deploy to AKS"
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

## Monitoring Workflow

### View Workflow Runs

- Go to Actions tab in GitHub repository
- Click on a workflow run to see details
- Expand each job to view logs

### Check Deployment Status

After workflow completes:

```bash
# Get AKS credentials
az aks get-credentials --resource-group rg-flipkart-app --name aks-flipkart-cluster

# Check deployments
kubectl get deployments

# Check pods
kubectl get pods

# Check service and get external IP
kubectl get service flipkartmobilepage-service
```

## Troubleshooting

### Workflow Fails at Azure Login

- Verify `AZURE_CREDENTIALS` secret is correctly configured
- Check Service Principal has Contributor role

### Docker Push Fails

- Ensure ACR exists and is accessible
- Verify ACR name matches in workflow environment variables

### AKS Deployment Fails

- Check AKS cluster is running: `az aks show --resource-group rg-flipkart-app --name aks-flipkart-cluster`
- Verify ACR is attached to AKS (configured by Terraform)

### External IP Not Assigned

- LoadBalancer service can take 2-5 minutes to get external IP
- Check: `kubectl get service flipkartmobilepage-service -w`

## Workflow Customization

### Change Replica Count

Edit `k8s/deployment.yaml`:

```yaml
spec:
  replicas: 3 # Change from 2 to 3
```

### Change Resource Limits

Edit `k8s/deployment.yaml`:

```yaml
resources:
  limits:
    memory: "1Gi" # Increase memory
    cpu: "1000m" # Increase CPU
```

### Deploy to Different Environment

Create separate workflow files for staging/production with different:

- Branch triggers
- Resource group names
- AKS cluster names
