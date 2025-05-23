# SQL Databases and related resources

# Catalog Database
resource "azurerm_mssql_database" "catalog" {
  name           = "sqldb-catalog"
  server_id      = azurerm_mssql_server.catalog.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"
  zone_redundant = false
  min_capacity   = 0
}

# Identity Database
resource "azurerm_mssql_database" "identity" {
  name           = "sqldb-identity"
  server_id      = azurerm_mssql_server.identity.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "Basic"
  zone_redundant = false
  min_capacity   = 0
}

# Firewall rules for Catalog database
resource "azurerm_mssql_firewall_rule" "catalog_allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.catalog.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

# Firewall rules for Identity database
resource "azurerm_mssql_firewall_rule" "identity_allow_all" {
  name             = "AllowAll"
  server_id        = azurerm_mssql_server.identity.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

# Store database connection strings in Key Vault
resource "azurerm_key_vault_secret" "catalog_admin_password" {
  name         = "CatalogSqlAdminPassword"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "identity_admin_password" {
  name         = "IdentitySqlAdminPassword"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "catalog_app_user_password" {
  name         = "CatalogAppUserPassword"
  value        = var.app_user_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "identity_app_user_password" {
  name         = "IdentityAppUserPassword"
  value        = var.app_user_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "catalog_connection_string" {
  name         = "CatalogConnectionString"
  value        = "Server=${azurerm_mssql_server.catalog.fully_qualified_domain_name};Database=${azurerm_mssql_database.catalog.name};User=${var.app_user_name};Password=${var.app_user_password}"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "identity_connection_string" {
  name         = "IdentityConnectionString"
  value        = "Server=${azurerm_mssql_server.identity.fully_qualified_domain_name};Database=${azurerm_mssql_database.identity.name};User=${var.app_user_name};Password=${var.app_user_password}"
  key_vault_id = azurerm_key_vault.kv.id
}