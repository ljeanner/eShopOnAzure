# SQL Databases and related resources

# Catalog Database
resource "azurerm_mssql_database" "catalog" {
  name           = "db-catalog"
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
  name           = "db-identity"
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

# Database user setup scripts
resource "azurerm_resource_group_deployment_script" "catalog_db_setup" {
  name                = "catalog-db-setup-script"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  retention_interval = "PT1H"
  cleanup_preference = "OnSuccess"

  command            = <<-EOT
    wget https://github.com/microsoft/go-sqlcmd/releases/download/v0.8.1/sqlcmd-v0.8.1-linux-x64.tar.bz2
    tar x -f sqlcmd-v0.8.1-linux-x64.tar.bz2 -C .

    cat <<SCRIPT_END > ./initDb.sql
    IF EXISTS (SELECT * FROM sys.database_principals WHERE name = '${var.app_user_name}')
    BEGIN
        DROP USER [${var.app_user_name}]
    END
    GO
    CREATE USER [${var.app_user_name}] WITH PASSWORD = '${var.app_user_password}'
    GO
    ALTER ROLE db_owner ADD MEMBER [${var.app_user_name}]
    GO
    SCRIPT_END

    ./sqlcmd -S ${azurerm_mssql_server.catalog.fully_qualified_domain_name} -d ${azurerm_mssql_database.catalog.name} -U ${var.sql_admin_username} -P '${var.sql_admin_password}' -i ./initDb.sql
  EOT

  environment_variables = {
    "APPUSERNAME"      = var.app_user_name
    "DBNAME"           = azurerm_mssql_database.catalog.name
    "DBSERVER"         = azurerm_mssql_server.catalog.fully_qualified_domain_name
    "SQLADMIN"         = var.sql_admin_username
  }

  secure_environment_variables = {
    "APPUSERPASSWORD" = var.app_user_password
    "SQLCMDPASSWORD"  = var.sql_admin_password
  }

  depends_on = [
    azurerm_mssql_database.catalog,
    azurerm_mssql_server.catalog
  ]
}

resource "azurerm_resource_group_deployment_script" "identity_db_setup" {
  name                = "identity-db-setup-script"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  
  retention_interval = "PT1H"
  cleanup_preference = "OnSuccess"

  command            = <<-EOT
    wget https://github.com/microsoft/go-sqlcmd/releases/download/v0.8.1/sqlcmd-v0.8.1-linux-x64.tar.bz2
    tar x -f sqlcmd-v0.8.1-linux-x64.tar.bz2 -C .

    cat <<SCRIPT_END > ./initDb.sql
    IF EXISTS (SELECT * FROM sys.database_principals WHERE name = '${var.app_user_name}')
    BEGIN
        DROP USER [${var.app_user_name}]
    END
    GO
    CREATE USER [${var.app_user_name}] WITH PASSWORD = '${var.app_user_password}'
    GO
    ALTER ROLE db_owner ADD MEMBER [${var.app_user_name}]
    GO
    SCRIPT_END

    ./sqlcmd -S ${azurerm_mssql_server.identity.fully_qualified_domain_name} -d ${azurerm_mssql_database.identity.name} -U ${var.sql_admin_username} -P '${var.sql_admin_password}' -i ./initDb.sql
  EOT

  environment_variables = {
    "APPUSERNAME"      = var.app_user_name
    "DBNAME"           = azurerm_mssql_database.identity.name
    "DBSERVER"         = azurerm_mssql_server.identity.fully_qualified_domain_name
    "SQLADMIN"         = var.sql_admin_username
  }

  secure_environment_variables = {
    "APPUSERPASSWORD" = var.app_user_password
    "SQLCMDPASSWORD"  = var.sql_admin_password
  }

  depends_on = [
    azurerm_mssql_database.identity,
    azurerm_mssql_server.identity
  ]
}

# Store database secrets in Key Vault
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

# Connection strings with app user credentials
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