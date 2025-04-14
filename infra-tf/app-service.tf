# App Service Plan
resource "azurerm_service_plan" "plan" {
  name                = "plan-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  os_type            = "Linux"
  sku_name           = "B1"
}

# Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = "appi-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  tags                = var.tags
  retention_in_days   = 90
}

# Web Application
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  tags                = var.tags

  site_config {
    always_on                = true
    ftps_state              = "FtpsOnly" 
    minimum_tls_version     = "1.2"
    app_command_line        = var.app_command_line
    health_check_path       = var.health_check_path
    
    application_stack {
      dotnet_version = "8.0"
    }

    cors {
      allowed_origins = var.allowed_origins
    }
  }

  identity {
    type = var.managed_identity ? "SystemAssigned" : "None"
  }

  app_settings = merge(
    var.app_settings,
    {
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "False"
      "ENABLE_ORYX_BUILD"              = "True"
      "AZURE_KEY_VAULT_ENDPOINT"       = azurerm_key_vault.kv.vault_uri
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
      "AZURE_SQL_CATALOG_CONNECTION_STRING_KEY" = "CatalogConnectionString"
      "AZURE_SQL_IDENTITY_CONNECTION_STRING_KEY" = "IdentityConnectionString"
      "ASPNETCORE_ENVIRONMENT" = "Production"
      "DOTNET_STARTUP_HOOKS" = ""
      "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
      "RUN_MIGRATIONS" = "true"
    }
  )

  logs {
    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }

    detailed_error_messages = true
    failed_request_tracing = true
  }

  client_affinity_enabled = var.client_affinity_enabled
}

# Grant Web App access to Key Vault
resource "azurerm_key_vault_access_policy" "webapp" {
  count = var.managed_identity ? 1 : 0

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  # Using Linux web app identity (NOT Windows)
  object_id    = azurerm_linux_web_app.webapp.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}