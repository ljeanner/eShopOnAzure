location = "westus2"
environment = "dev"

tags = {
  Environment = "dev"
  Project     = "MyApplication"
  Owner       = "DevOps Team"
  Terraform   = "true"
}

# Note: In a real environment, these sensitive values should never be committed to version control
sql_admin_username = "sqladmin"
sql_admin_password = "P@ssw0rd123!#Complex"

azure_ad_admin_username = "admin@contoso.com"
azure_ad_admin_object_id = "12345678-1234-1234-1234-123456789012"

app_user_name = "appuser"
app_user_password = "AppP@ssw0rd123!#Complex"

principal_id = ""

# App Service Configuration
runtime_name = "dotnet"
runtime_version = "v8.0"
always_on = true
client_affinity_enabled = false
enable_oryx_build = true
scm_do_build_during_deployment = false
use_32_bit_worker_process = false
ftps_state = "FtpsOnly"
health_check_path = "/health"
managed_identity = true

app_settings = {
  "WEBSITE_TIME_ZONE" = "UTC"
}