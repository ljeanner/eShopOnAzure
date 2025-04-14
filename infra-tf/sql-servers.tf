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

# Deployment Script for User Management
resource "azurerm_resource_group" "deployment_script_rg" {
  name     = "deployment-script-rg"
  location = azurerm_resource_group.rg.location
}

resource "azurerm_storage_account" "deployment_script_sa" {
  name                     = "deploymentscript${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_container_registry" "deployment_script_acr" {
  name                = "deploymentscriptacr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

# Replacing unsupported azurerm_deployment_script_azure_cli with azurerm_virtual_machine_extension
resource "azurerm_virtual_machine_extension" "sql_user_setup" {
  name                 = "sql-user-setup"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "commandToExecute": "az sql user create --name ${var.app_user_name} --password ${var.app_user_password} --database ${azurerm_mssql_database.catalog.name} --server ${azurerm_mssql_server.catalog.fully_qualified_domain_name} --admin-user ${var.sql_admin_username} --admin-password ${var.sql_admin_password}"
    }
SETTINGS

  tags = var.tags
}

# Define the azurerm_virtual_machine resource
resource "azurerm_virtual_machine" "vm" {
  name                  = "vm${random_string.suffix.result}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "osdisk${random_string.suffix.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}

# Define the azurerm_network_interface resource
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Define the azurerm_subnet resource
resource "azurerm_subnet" "vm_subnet" {
  name                 = "snet-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the azurerm_virtual_network resource
resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vnet-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}