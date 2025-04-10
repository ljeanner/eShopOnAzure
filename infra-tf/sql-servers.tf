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

# Catalog Firewall Rule allowing Azure services and all client IPs
resource "azurerm_mssql_firewall_rule" "catalog_allow_all" {
  name             = "AllowAllClients"
  server_id        = azurerm_mssql_server.catalog.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

# Catalog Database
resource "azurerm_mssql_database" "catalog_db" {
  name                 = var.catalog_database_name
  server_id            = azurerm_mssql_server.catalog.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  sku_name             = "Basic"
  zone_redundant       = false
  storage_account_type = "Local"
}

# Identity Firewall Rule allowing Azure services and all client IPs
resource "azurerm_mssql_firewall_rule" "identity_allow_all" {
  name             = "AllowAllClients"
  server_id        = azurerm_mssql_server.identity.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

# Identity Database
resource "azurerm_mssql_database" "identity_db" {
  name                 = var.identity_database_name
  server_id            = azurerm_mssql_server.identity.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  sku_name             = "Basic"
  zone_redundant       = false
  storage_account_type = "Local"
}

# Store connection strings in Key Vault
resource "azurerm_key_vault_secret" "catalog_connection_string" {
  name         = "AZURE-SQL-CATALOG-CONNECTION-STRING"
  value        = "Server=tcp:${azurerm_mssql_server.catalog.fully_qualified_domain_name},1433;Initial Catalog=${var.catalog_database_name};Persist Security Info=False;User ID=${var.app_user_name};Password=${var.app_user_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "identity_connection_string" {
  name         = "AZURE-SQL-IDENTITY-CONNECTION-STRING"
  value        = "Server=tcp:${azurerm_mssql_server.identity.fully_qualified_domain_name},1433;Initial Catalog=${var.identity_database_name};Persist Security Info=False;User ID=${var.app_user_name};Password=${var.app_user_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv.id
}