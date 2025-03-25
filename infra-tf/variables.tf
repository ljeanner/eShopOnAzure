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

variable "principal_id" {
  description = "The principal ID for the default Key Vault access policy"
  type        = string
  default     = ""
}

# App Service Variables
variable "runtime_name" {
  description = "The runtime stack for the web app"
  type        = string
  default     = "dotnet"
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

variable "always_on" {
  description = "Whether the web app should always be loaded"
  type        = bool
  default     = true
}

variable "app_command_line" {
  description = "Custom startup command for the app"
  type        = string
  default     = ""
}

variable "allowed_origins" {
  description = "Additional allowed CORS origins"
  type        = list(string)
  default     = []
}

variable "client_affinity_enabled" {
  description = "Whether to enable client affinity"
  type        = bool
  default     = false
}

variable "enable_oryx_build" {
  description = "Whether to enable Oryx build"
  type        = bool
  default     = true
}

variable "scm_do_build_during_deployment" {
  description = "Whether to enable build during deployment"
  type        = bool
  default     = false
}

variable "use_32_bit_worker_process" {
  description = "Whether to use 32-bit worker process"
  type        = bool
  default     = false
}

variable "ftps_state" {
  description = "The FTPS state for the web app"
  type        = string
  default     = "FtpsOnly"
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = ""
}

variable "managed_identity" {
  description = "Whether to enable managed identity"
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Additional application settings"
  type        = map(string)
  default     = {}
}