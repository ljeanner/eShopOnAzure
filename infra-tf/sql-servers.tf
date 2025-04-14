# SQL Servers
resource "azurerm_mssql_server" "catalog" {
  name                         = "sql-catalog-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = var.azure_ad_admin_username
    object_id      = var.azure_ad_admin_object_id
  }
}

resource "azurerm_mssql_server" "identity" {
  name                         = "sql-identity-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = var.azure_ad_admin_username
    object_id      = var.azure_ad_admin_object_id
  }
}

# Create SQL users for both databases using deployment scripts
resource "azurerm_resource_group_template_deployment" "catalog_user_setup" {
  name                = "catalog-user-setup"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Resources/deploymentScripts",
      "apiVersion": "2020-10-01",
      "name": "catalogDbUserSetup",
      "location": "${azurerm_resource_group.rg.location}",
      "kind": "AzureCLI",
      "properties": {
        "azCliVersion": "2.30.0",
        "retentionInterval": "P1D",
        "environmentVariables": [
          {
            "name": "SQLADMIN",
            "value": "${var.sql_admin_username}"
          },
          {
            "name": "SQLPASSWORD", 
            "secureValue": "${var.sql_admin_password}"
          },
          {
            "name": "APPUSERNAME",
            "value": "${var.app_user_name}"
          },
          {
            "name": "APPUSERPASSWORD",
            "secureValue": "${var.app_user_password}"
          }
        ],
        "scriptContent": "az sql db user create --resource-group ${azurerm_resource_group.rg.name} --server ${azurerm_mssql_server.catalog.name} --database ${azurerm_mssql_database.catalog.name} --name \"${var.app_user_name}\" --password \"${var.app_user_password}\" && az sql db role create --resource-group ${azurerm_resource_group.rg.name} --server ${azurerm_mssql_server.catalog.name} --database ${azurerm_mssql_database.catalog.name} --name \"db_owner\" --members \"${var.app_user_name}\" || echo \"Role may already exist\""
      }
    }
  ]
}
TEMPLATE

  depends_on = [
    azurerm_mssql_database.catalog
  ]
}

resource "azurerm_resource_group_template_deployment" "identity_user_setup" {
  name                = "identity-user-setup"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode     = "Incremental"
  
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Resources/deploymentScripts",
      "apiVersion": "2020-10-01",
      "name": "identityDbUserSetup",
      "location": "${azurerm_resource_group.rg.location}",
      "kind": "AzureCLI",
      "properties": {
        "azCliVersion": "2.30.0",
        "retentionInterval": "P1D",
        "environmentVariables": [
          {
            "name": "SQLADMIN",
            "value": "${var.sql_admin_username}"
          },
          {
            "name": "SQLPASSWORD", 
            "secureValue": "${var.sql_admin_password}"
          },
          {
            "name": "APPUSERNAME",
            "value": "${var.app_user_name}"
          },
          {
            "name": "APPUSERPASSWORD",
            "secureValue": "${var.app_user_password}"
          },
          {
            "name": "DBSERVER",
            "value": "${azurerm_mssql_server.identity.fully_qualified_domain_name}"
          },
          {
            "name": "DATABASE",
            "value": "${azurerm_mssql_database.identity.name}"
          }
        ],
        "scriptContent": "az sql db user create --resource-group ${azurerm_resource_group.rg.name} --server ${azurerm_mssql_server.identity.name} --database ${azurerm_mssql_database.identity.name} --name \"${var.app_user_name}\" --password \"${var.app_user_password}\" && az sql query --resource-group ${azurerm_resource_group.rg.name} --server ${azurerm_mssql_server.identity.name} --database ${azurerm_mssql_database.identity.name} --query \"ALTER ROLE db_owner ADD MEMBER [${var.app_user_name}];\""
      }
    }
  ]
}
TEMPLATE

  depends_on = [
    azurerm_mssql_database.identity
  ]
}