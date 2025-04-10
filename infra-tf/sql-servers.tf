# SQL Servers
resource "azurerm_mssql_server" "catalog" {
  name                         = "sql-catalog-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

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

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = var.azure_ad_admin_username
    object_id      = var.azure_ad_admin_object_id
  }
}