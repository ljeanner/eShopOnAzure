output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "web_app_name" {
  description = "The name of the web app"
  value       = azurerm_linux_web_app.webapp.name
}

output "web_app_url" {
  description = "The default URL of the web app"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "catalog_db_name" {
  description = "The name of the catalog database"
  value       = azurerm_mssql_database.catalog.name
}

output "identity_db_name" {
  description = "The name of the identity database"
  value       = azurerm_mssql_database.identity.name
}

output "catalog_server_fqdn" {
  description = "The fully qualified domain name of the catalog SQL server"
  value       = azurerm_mssql_server.catalog.fully_qualified_domain_name
}

output "identity_server_fqdn" {
  description = "The fully qualified domain name of the identity SQL server"
  value       = azurerm_mssql_server.identity.fully_qualified_domain_name
}