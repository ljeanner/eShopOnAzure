# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"
  tags               = var.tags

  # Grant permissions to the current service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge"
    ]
  }

  # Default access policy if principal ID is provided
  dynamic "access_policy" {
    for_each = var.principal_id != "" ? [1] : []
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = var.principal_id

      secret_permissions = [
        "Get",
        "List"
      ]
    }
  }
}

# Store SQL connection strings in Key Vault
resource "azurerm_key_vault_secret" "catalog_connection" {
  name         = "CatalogConnectionString"
  value        = "Server=tcp:${azurerm_mssql_server.catalog.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.catalog.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};Encrypt=true;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "identity_connection" {
  name         = "IdentityConnectionString"
  value        = "Server=tcp:${azurerm_mssql_server.identity.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.identity.name};User ID=${var.sql_admin_username};Password=${var.sql_admin_password};Encrypt=true;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
}