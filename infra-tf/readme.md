1. Configure Azure for Terraform
The pipeline uses Terraform to interact with Azure. You must ensure that the Azure credentials (the secrets mentioned below) are properly configured:

Create a Service Principal in Azure using the following command:
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"

This will generate the values for AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_SUBSCRIPTION_ID, and AZURE_TENANT_ID.


2. Configure GitHub Secrets
The secrets mentioned in the workflow file (AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, and GITHUB_TOKEN) must be configured in the GitHub repository. Here's how to add them:

Go to your GitHub repository.
Click on Settings.
In the left menu, find Secrets and variables > Actions.
Click on New repository secret.
Add the following secrets:
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
GITHUB_TOKEN (This secret is automatically provided by GitHub Actions, so you don't need to configure it manually.)

3. Trigger the Workflow
The workflow is automatically triggered in the following cases:
push to the main branch: Executes the pipeline and applies the changes (terraform apply).
pull_request to the main branch: Executes the terraform plan steps and comments the results in the pull request.
You can also trigger it manually from (.github/workflows/terraform.yml)