output "avx_controller_public_ip" {
  value = module.aviatrix_controller_build.aviatrix_controller_public_ip_address
}

output "avx_controller_private_ip" {
  value = module.aviatrix_controller_build.aviatrix_controller_private_ip_address
}

output "avx_controller_vnet" {
  value = module.aviatrix_controller_build.aviatrix_controller_vnet
}

output "avx_controller_rg" {
  value = module.aviatrix_controller_build.aviatrix_controller_rg
}

output "avx_controller_subnet" {
  value = module.aviatrix_controller_build.aviatrix_controller_subnet
}

output "avx_controller_name" {
  value = module.aviatrix_controller_build.aviatrix_controller_name
}


/*
# copilot

output "copilot_public_ip" {
  value = module.copilot_build_azure.public_ip
}

output "copilot_private_ip" {
  value = module.copilot_build_azure.private_ip
}
*/