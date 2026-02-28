########################################################################################################################
# Outputs
########################################################################################################################

output "ease_instance" {
  description = "Details of the Enterprise Application Service instance."
  value       = ibm_resource_instance.ease_instance
}
