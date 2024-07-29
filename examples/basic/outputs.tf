########################################################################################################################
# Outputs
########################################################################################################################

output "liberty_aas_name" {
  description = "Name of Liberty as a Service instance"
  value       = ibm_resource_instance.liberty_aas_instance.id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
}
