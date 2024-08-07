########################################################################################################################
# Outputs
########################################################################################################################

output "liberty_aas_name" {
  description = "Name of Liberty as a Service instance"
  value       = ibm_resource_instance.liberty_aas_instance.name
}
