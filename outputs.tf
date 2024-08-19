########################################################################################################################
# Outputs
########################################################################################################################

output "ease_name" {
  description = "Name of Enterprise Application Service instance"
  value       = ibm_resource_instance.ease_instance.name
}
