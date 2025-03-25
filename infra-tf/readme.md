# Azure Terraform Setup Guide

This guide explains how to set up Azure credentials and GitHub Actions for Terraform deployments.

## 1. Azure Configuration for Terraform

To use Terraform with Azure in our workflows, we need the following credentials:
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

### Get Azure Subscription and Tenant IDs

```bash
# Get Subscription ID
az account show --query id --output tsv

# Get Tenant ID
az account show --query tenantId --output tsv
```

### Create Azure Service Principal

Create a Service Principal in Azure with Contributor access:

```bash
az ad sp create-for-rbac \
  --role="Contributor" \
  --scopes="/subscriptions/<AZURE_SUBSCRIPTION_ID>"
```

The command will generate output similar to:

```json
{
  "appId": "AZURE_CLIENT_ID",
  "displayName": "azure-cli-2025-03-25-08-46-11",
  "password": "AZURE_CLIENT_SECRET",
  "tenant": "AZURE_TENANT_ID"
}
```

> **Important**: Save these credentials securely as they will be needed for GitHub Actions configuration.

## 2. GitHub Actions Configuration

### Setting Up Repository Secrets

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click on **New repository secret**
4. Add the following secrets:

| Secret Name | Description |
|------------|-------------|
| `AZURE_CLIENT_ID` | Service Principal App ID |
| `AZURE_CLIENT_SECRET` | Service Principal Password |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `AZURE_TENANT_ID` | Azure Tenant ID |

> **Note**: `GITHUB_TOKEN` is automatically provided by GitHub Actions and doesn't need manual configuration.

## 3. Workflow Triggers

The GitHub Actions workflow (`.github/workflows/terraform.yml`) is configured with the following triggers:

### Automatic Triggers

| Event | Branch | Action |
|-------|--------|--------|
| Push | `main` | Runs `terraform apply` |
| Pull Request | `main` | Runs `terraform plan` |

### Workflow Details

- **Push to Main**:
  - Initializes Terraform
  - Validates configurations
  - Automatically applies changes
  - Updates infrastructure

- **Pull Request**:
  - Runs format check
  - Validates configurations
  - Creates plan
  - Comments plan results in PR

### Manual Trigger

You can also trigger the workflow manually through the GitHub Actions UI:

1. Go to the **Actions** tab
2. Select the **Terraform CI/CD** workflow
3. Click **Run workflow**
4. Choose the branch and trigger the workflow

## Security Considerations

- Keep all credentials secure and never commit them to the repository
- Regularly rotate the Service Principal credentials
- Review and audit GitHub Actions logs
- Monitor Azure Activity Logs for deployed resources

## Troubleshooting

If you encounter issues:

1. Verify Azure credentials are correct and not expired
2. Ensure Service Principal has sufficient permissions
3. Check GitHub Actions logs for detailed error messages
4. Validate Terraform configuration files locally before pushing

## Additional Resources

- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Documentation](https://www.terraform.io/docs)