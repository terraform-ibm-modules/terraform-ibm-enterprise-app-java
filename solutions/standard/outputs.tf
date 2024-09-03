########################################################################################################################
# Outputs
########################################################################################################################

output "ease_instance" {
  description = "Enterprise Application Service instance details"
  value       = data.ibm_resource_instance.ease_resource
}
