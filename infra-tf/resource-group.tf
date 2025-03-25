# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-application-${random_string.suffix.result}"
  location = var.location
  tags     = var.tags
}