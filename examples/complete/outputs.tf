########################################################################################################################
# Outputs
########################################################################################################################

output "ease_instance" {
  description = "Enterprise Application Service instance details"
  value       = data.ibm_resource_instance.ease_resource
}

output "ease_application_dashboard_url" {
  description = "Enterprise Application Service instance dashboard URL"
  value       = local.app_dashboard_url
}
