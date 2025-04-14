variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "westus2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "azure_ad_admin_username" {
  description = "Azure AD administrator username"
  type        = string
}

variable "azure_ad_admin_object_id" {
  description = "Azure AD administrator object ID"
  type        = string
}

variable "app_user_name" {
  description = "Application database user name"
  type        = string
  default     = "appuser"
}

variable "app_user_password" {
  description = "Application database user password"
  type        = string
  sensitive   = true
}

variable "catalog_database_name" {
  description = "The name of the catalog database"
  type        = string
  default     = "db-catalog"
}

variable "identity_database_name" {
  description = "The name of the identity database"
  type        = string
  default     = "db-identity"
}

variable "principal_id" {
  description = "The principal ID for the default Key Vault access policy"
  type        = string
  default     = ""
}

# App Service Variables
variable "runtime_name" {
  description = "The runtime stack for the web app"
  type        = string
  default     = "dotnet-isolated"
  validation {
    condition     = contains(["dotnet", "dotnetcore", "dotnet-isolated", "node", "python", "java", "powershell", "custom"], var.runtime_name)
    error_message = "Runtime name must be one of: dotnet, dotnetcore, dotnet-isolated, node, python, java, powershell, custom"
  }
}

variable "runtime_version" {
  description = "The version of the runtime stack"
  type        = string
  default     = "v8.0"
}

variable "app_settings" {
  description = "Additional application settings"
  type        = map(string)
  default     = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "False"
    "ENABLE_ORYX_BUILD"              = "True"
    "AZURE_KEY_VAULT_ENDPOINT"       = ""
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = ""
    "AZURE_SQL_CATALOG_CONNECTION_STRING_KEY" = "CatalogConnectionString"
    "AZURE_SQL_IDENTITY_CONNECTION_STRING_KEY" = "IdentityConnectionString"
    "ASPNETCORE_ENVIRONMENT" = "Production"
  }
}

# VM Admin Credentials
variable "admin_username" {
  description = "Administrator username for the virtual machine"
  type        = string
  default     = "vmadmin"
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password for the virtual machine"
  type        = string
  sensitive   = true
}

# App Service Additional Variables
variable "app_command_line" {
  description = "The startup command for the web app"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "The path to the health check endpoint"
  type        = string
  default     = "/health"
}

variable "allowed_origins" {
  description = "A list of origins that are allowed to make cross-origin calls"
  type        = list(string)
  default     = ["*"]
}

variable "managed_identity" {
  description = "Whether to enable managed identity for the web app"
  type        = bool
  default     = true
}

variable "client_affinity_enabled" {
  description = "Whether to enable client affinity for the web app"
  type        = bool
  default     = false
}