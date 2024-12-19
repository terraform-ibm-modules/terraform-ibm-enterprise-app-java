########################################################################################################################
# Outputs
########################################################################################################################

output "ease_instance_dashboard_url" {
  description = "Enterprise Application Service instance dashboard URL"
  value       = local.app_dashboard_url
}

output "ease_instance_crn" {
  description = "Enterprise Application Service instance crn"
  value       = data.ibm_resource_instance.ease_resource.crn
}

output "ease_instance_id" {
  description = "Enterprise Application Service instance id"
  value       = data.ibm_resource_instance.ease_resource.id
}

output "ease_instance_guid" {
  description = "Enterprise Application Service instance guid"
  value       = data.ibm_resource_instance.ease_resource.guid
}

output "ease_instance_location" {
  description = "Enterprise Application Service instance location"
  value       = data.ibm_resource_instance.ease_resource.location
}

output "ease_instance_name" {
  description = "Enterprise Application Service instance name"
  value       = data.ibm_resource_instance.ease_resource.name
}

output "ease_instance_resource_group_id" {
  description = "Enterprise Application Service instance resource group id"
  value       = data.ibm_resource_instance.ease_resource.resource_group_id
}

output "ease_instance_resource_status" {
  description = "Enterprise Application Service instance resource status"
  value       = data.ibm_resource_instance.ease_resource.resource_status
}
