# Launch an Aviatrix Controller in Azure China

## Description

These Terraform modules launch an Aviatrix Controller in Azure China and create an access account on the controller. It allows to specify the Certificate Domain, which must be a domain with an ICP registration. This is a requirement for controllers deployed in China. 
It also allows to specify an Azure storage account to enable backups.

Controller instance size (Standard_B2ms)
Copilot deployment code is also added here.   (default instance size Standard_D2s_v3)


## Prerequisites

1. [Terraform v0.13+](https://www.terraform.io/downloads.html) - execute terraform files
2. [Python3](https://www.python.org/downloads/) - execute `accept_license.py` and `aviatrix_controller_init.py` python
   scripts

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | \>= 2.0 |
| <a name="provider_null"></a> [null](#provider\_null) | \>= 2.0 |


## Available Modules

Module  | Description |
| ------- | ----------- |
|[aviatrix_controller_build](modules/aviatrix_controller_build) |Builds the Aviatrix Controller VM on Azure |
|[aviatrix_controller_initialize](modules/aviatrix_controller_initialize) | Initializes the Aviatrix Controller (setting admin email, setting admin password, upgrading controller version, and setting up access account. Optionally allows specifying an Azure storage account to enable backups and provide a Certificate Domain) |
|[copilot_build_azurecn] - https://github.com/patelavtx/copilot_build_azurecn.git -  deploys copilot in CN


## Procedures for Building and Initializing a Controller in Azure

### 1. Create the Python virtual environment and install required dependencies

Install Python3.9 virtual environment.

``` shell
sudo apt install python3.9-venv
```

Create the virtual environment.

``` shell
python3.9 -m venv venv
```

Activate the virtual environment.

``` shell
source venv/bin/activate
```

Install Python3.9-pip

``` shell
sudo apt install python3.9-distutils
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py
```

Install required dependencies.

``` shell
pip install -r requirements.txt
```

### 2. Authenticating to Azure

Set the environment in Azure CLI to Azure China:

```shell
az cloud set -n AzureChinaCloud
```

Login to the Azure CLI using:

```shell
az login --use-device-code
````
*Note: Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs#authenticating-to-azure-active-directory) for different methods of authentication to Azure, incase above command is not applicable.*

Pick the subscription you want and use it in the command below.

```shell
az account set --subscription <subscription_id>
```

Set environment variables ARM_ENDPOINT and ARM_ENVIRONMENT to use Azure China endpoints:

  ``` shell
  export ARM_ENDPOINT=https://management.chinacloudapi.cn
  export ARM_ENVIRONMENT=china
  ```

If executing this code from a CI/CD pipeline, the following environment variables are required. The service principal used to authenticate the CI/CD tool into Azure must either have subscription owner role or a custom role that has `Microsoft.Authorization/roleAssignments/write` to be able to succesfully create the role assignments required

``` shell
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```


### 3. Applying Terraform configuration 

Build and initialize the Aviatrix Controller

```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

# controller build
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


# controller initialize (needs specific python venv - controller can be configured manually by commenting out this module)
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
  count 			 = var.enablecop ? 1 : 0  
  copilot_name                   = var.copilot_name
  add_ssh_key			 = var.add_ssh_key
  virtual_machine_admin_username = var.virtual_machine_admin_username
  virtual_machine_admin_password = var.virtual_machine_admin_password
  location                       = var.location
  use_existing_vnet              = var.use_existing_vnet
  virtual_machine_size           = var.virtual_machine_size            # default
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


**### 4. Applying Terraform configuration 
**
avtx_service_principal_appid = 
avtx_service_principal_secret = 
aviatrix_customer_id = 
avx_controller_admin_password = 
controller_version = "7.0.2239"
controller_name = "azCN-ctl-cne"
controller_vnet_cidr = "10.190.190.0/24"
controller_subnet_cidr = "10.190.190.0/24"

storage_account_name = "azcnctlcne"
storage_account_container = "azcnctlcne"
storage_account_region = "China East"

enable_backup = "true"
enable_multiple_backup = "true"
icp_certificate_domain = "domain.com"               # needed as authorized to use to deploy in CN - alibaba avtx gws fail via TF during ssl init connection if not present






```

*Execute*

```shell
terraform init
terraform apply
```
