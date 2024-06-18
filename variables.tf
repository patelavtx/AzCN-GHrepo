variable "avx_access_account_name" {
  type        = string
  description = "aviatrix controller access account name"
  default = "AzCN-proj"
}

variable "avx_account_email" {
  type        = string
  description = "aviatrix controller access account email"
  default = "apatel@aviatrix.com"
}

variable "aviatrix_customer_id" {
  type        = string
  description = "aviatrix customer license id"
}

variable "avx_controller_admin_email" {
  type        = string
  description = "aviatrix controller admin email address"
  default = "apatel@aviatrix.com"
}

variable "avx_controller_admin_password" {
  type        = string
  description = "aviatrix controller admin password"
  default = "Aviatrix123#"
}

variable "controller_name" {
  type        = string
  description = "Customized Name for Aviatrix Controller"
}

variable "controller_subnet_cidr" {
  type        = string
  description = "CIDR for controller subnet."
  default     = "10.190.190.0/24"
}

variable "controller_version" {
  type        = string
  description = "Aviatrix Controller version"
  default     = "latest"
}

variable "controller_virtual_machine_admin_username" {
  type        = string
  description = "Admin Username for the controller virtual machine."
  default     = "aviatrix"
}

variable "controller_virtual_machine_admin_password" {
  type        = string
  description = "Admin Password for the controller virtual machine."
  default     = "aviatrix1234!"
}

variable "controller_virtual_machine_size" {
  type        = string
  description = "Virtual Machine size for the controller."
  default     = "Standard_A4_v2"
}

variable "controller_vnet_cidr" {
  type        = string
  description = "CIDR for controller VNET."
  default     = "10.190.190.0/24"
}

variable "location" {
  type        = string
  description = "Resource Group Location for Aviatrix Controller"
  default     = "China North"
}

variable "avtx_service_principal_secret" {
  type = string
  description = "This is the secret of the AppID created for the Aviatrix Controller"
  sensitive = true
}

variable "avtx_service_principal_appid" {
  type = string
  description = "This is the AppID of the Service Principal created for the Aviatrix Controller"
  sensitive = true
}

variable "incoming_ssl_cidr" {
  type        = list(string)
  description = "Incoming cidr for security group used by controller"
  default = []
}

variable "storage_account_name" {
  type        = string
  description = "Azure storage account used to store the backup"
  default     = ""
}

variable "storage_account_container" {
  type        = string
  description = "Azure storage account container used to store the backup"
  default     = ""
}

variable "storage_account_region" {
  type        = string
  description = "Azure region where "
  default     = ""
}

variable "enable_multiple_backup" {
  type        = bool
  description = "Choose whether to enable multiple backups for the controller"
  default     = false
}

variable "enable_backup" {
  type        = bool
  description = "Whether to enable backup using the storage account created as part of this module. Set to false if you plan to restore from an existing backup"
  default     = false
}

variable "icp_certificate_domain" {
  type = string
  description = "ICP Certificate domain. It can be added afterwards if it is not currently available"
}

locals {
  provisionerIP = [replace(data.http.my_ip.response_body,"\n","/32")]
  m_backup = var.enable_multiple_backup ? "true" : "false"
  e_backup = var.enable_backup ? "true" : "false"
  allowed_ips = length(var.incoming_ssl_cidr) > 0 ? concat(var.incoming_ssl_cidr,local.provisionerIP) : local.provisionerIP
  icp_domain = var.icp_certificate_domain == null ? "false" : var.icp_certificate_domain
}


# copilot
variable "enablecop" {
  default     = "true"
}

variable "copilot_name" {
  type = string
  default = "azcn-coptest"
}

variable "use_existing_vnet" {
  type = string
  default = "true"
}

variable "add_ssh_key" {
  type = string
  default = "false"
}

variable "virtual_machine_size" {
  type        = string
  description = ""
  default     = "Standard_A4_v2"
}

variable "virtual_machine_admin_username" {
  type        = string
  description = ""
  default     = "copadmin"
}

variable "virtual_machine_admin_password" {
  type        = string
  description = ""
  default     = "Aviatrix123#"
}

variable "default_data_disk_size" {
  type = string
  default = "30"
}