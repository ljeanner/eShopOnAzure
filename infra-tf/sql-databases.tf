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
 
 # SQL Database user setup for Catalog Database
resource "null_resource" "setup_catalog_db_user" {
  depends_on = [azurerm_mssql_database.catalog]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $connectionString = "Server=tcp:${azurerm_mssql_server.catalog.fully_qualified_domain_name},1433;Initial Catalog=${var.catalog_database_name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
      
      $query = @"
      IF EXISTS (SELECT * FROM sys.database_principals WHERE name = '${var.app_user_name}')
      BEGIN
          DROP USER [${var.app_user_name}]
      END
      GO
      CREATE USER [${var.app_user_name}] WITH PASSWORD = '${var.app_user_password}'
      GO
      ALTER ROLE db_owner ADD MEMBER [${var.app_user_name}]
      GO
      "@

      $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
      try {
          $conn.Open()
          $cmd = New-Object System.Data.SqlClient.SqlCommand($query, $conn)
          $cmd.ExecuteNonQuery()
      }
      finally {
          $conn.Close()
      }
    EOT
  }
}

# SQL Database user setup for Identity Database
resource "null_resource" "setup_identity_db_user" {
  depends_on = [azurerm_mssql_database.identity]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
      $connectionString = "Server=tcp:${azurerm_mssql_server.identity.fully_qualified_domain_name},1433;Initial Catalog=${var.identity_database_name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
      
      $query = @"
      IF EXISTS (SELECT * FROM sys.database_principals WHERE name = '${var.app_user_name}')
      BEGIN
          DROP USER [${var.app_user_name}]
      END
      GO
      CREATE USER [${var.app_user_name}] WITH PASSWORD = '${var.app_user_password}'
      GO
      ALTER ROLE db_owner ADD MEMBER [${var.app_user_name}]
      GO
      "@

      $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
      try {
          $conn.Open()
          $cmd = New-Object System.Data.SqlClient.SqlCommand($query, $conn)
          $cmd.ExecuteNonQuery()
      }
      finally {
          $conn.Close()
      }
    EOT
  }
}