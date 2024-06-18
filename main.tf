terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.8.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    null = {
      source = "hashicorp/null"
    }    
      http = {
      source = "hashicorp/http"
      version = "3.2.1"
    }
  }
}

data "azurerm_subscription" "current" {
}

data "http" "my_ip" {
#Get public IP address of system running the code to add to allowed IP addresses of Aviatrix Controller NSG
    url = "http://ipv4.icanhazip.com/"
    method = "GET"
}

module "aviatrix_controller_build" {
  #source = "./modules/aviatrix_controller_build"
  source = "github.com/patelavtx/aviatrix_controller_azure_china/modules/aviatrix_controller_build"
  controller_name                           = var.controller_name
  location                                  = var.location
  controller_vnet_cidr                      = var.controller_vnet_cidr
  controller_subnet_cidr                    = var.controller_subnet_cidr
  controller_virtual_machine_admin_username = var.controller_virtual_machine_admin_username
  controller_virtual_machine_admin_password = var.controller_virtual_machine_admin_password
  controller_virtual_machine_size           = var.controller_virtual_machine_size
  incoming_ssl_cidr                         = local.allowed_ips
}
module "aviatrix_controller_initialize" {
  #source                        = "./modules/aviatrix_controller_initialize"
  source = "github.com/patelavtx/aviatrix_controller_azure_china/modules/aviatrix_controller_initialize"
  avx_controller_public_ip      = module.aviatrix_controller_build.aviatrix_controller_public_ip_address
  avx_controller_private_ip     = module.aviatrix_controller_build.aviatrix_controller_private_ip_address
  avx_controller_admin_email    = var.avx_controller_admin_email
  avx_controller_admin_password = var.avx_controller_admin_password
  arm_subscription_id           = data.azurerm_subscription.current.subscription_id
  arm_application_id            = var.avtx_service_principal_appid
  arm_application_key           = var.avtx_service_principal_secret
  directory_id                  = data.azurerm_subscription.current.tenant_id
  account_email                 = var.avx_account_email
  access_account_name           = var.avx_access_account_name
  aviatrix_customer_id          = var.aviatrix_customer_id
  controller_version            = var.controller_version
  enable_backup                 = var.enable_backup
  multiple_backup               = var.enable_multiple_backup
  icp_certificate_domain        = var.icp_certificate_domain  
}


# copilot
module "copilot_build_azure" {
  source = "github.com/patelavtx/copilot_build_azurecn"                                                                # added to GH repo with updated image
  #source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"    #  inherent 'plan' statement causes failure
  #source = "../AzCN_cop"                                                                                              #  local repo with updated image 
  count 			 = var.enablecop ? 1 : 0  
  copilot_name                   = var.copilot_name
  add_ssh_key			 = var.add_ssh_key
  virtual_machine_admin_username = var.virtual_machine_admin_username
  virtual_machine_admin_password = var.virtual_machine_admin_password
  location                       = var.location
  use_existing_vnet              = var.use_existing_vnet
  virtual_machine_size           = var.virtual_machine_size            # Standard_D2s_v3
  resource_group_name            = module.aviatrix_controller_build.aviatrix_controller_rg.name
  subnet_id                      = module.aviatrix_controller_build.aviatrix_controller_subnet.id
  default_data_disk_size         = var.default_data_disk_size
  controller_public_ip           = module.aviatrix_controller_build.aviatrix_controller_public_ip_address
  controller_private_ip          = module.aviatrix_controller_build.aviatrix_controller_private_ip_address
  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["0.0.0.0/0"]
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }

  }

  #additional_disks = {
  #  "one" = {
  #    managed_disk_id = azurerm_managed_disk.source.id
  #    lun             = "1"
  #  }
    #  "two" = {
    #   managed_disk_id = "<< managed disk id 2 >>"
    #  lun = "2"
    #  }
  #}
  depends_on = [
    module.aviatrix_controller_build
  ]
}
