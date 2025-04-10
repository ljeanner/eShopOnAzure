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

# Note: Database, firewall rules, and connection strings are defined in sql-databases.tf