########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name where Enterprise Application Service instance is created"
  value       = module.resource_group.resource_group_name
}

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

output "mq_capacity_instance_crn" {
  description = "MQ capacity instance crn"
  value       = var.mq_s2s_policy_target_crn != null ? var.mq_s2s_policy_target_crn : null
}

output "mq_s2s_policy_id_crn_scope" {
  description = "Service to Service policy id to MQ capacity instance"
  value       = var.mq_s2s_policy_enable == true && var.mq_s2s_policy_target_crn != null ? ibm_iam_authorization_policy.mq_s2s_policy_crn_scope[0].id : null
}

output "mq_s2s_policy_id_account_scope" {
  description = "Service to Service policy id to MQ service with account scope"
  value       = var.mq_s2s_policy_enable == true && var.mq_s2s_policy_target_crn == null ? ibm_iam_authorization_policy.mq_s2s_policy_account_scope[0].id : null
}

output "mq_s2s_resource_id" {
  description = "Target Resource ID for the Service to Service policy for MQ capacity instance"
  value       = var.mq_s2s_policy_target_crn != null ? module.crn_parser_mq_capacity_instance_crn[0].service_instance : null
}

output "db2_instance_crn" {
  description = "DB2 instance crn"
  value       = var.db2_s2s_policy_target_crn != null ? var.db2_s2s_policy_target_crn : null
}

output "db2_s2s_policy_id_crn_scope" {
  description = "Service to Service policy id for DB2 instance"
  value       = var.db2_s2s_policy_enable == true && var.db2_s2s_policy_target_crn != null ? ibm_iam_authorization_policy.db2_s2s_policy_crn_scope[0].id : null
}

output "db2_s2s_policy_id_account_scope" {
  description = "Service to Service policy id to DB2 service with account scope"
  value       = var.db2_s2s_policy_enable == true && var.db2_s2s_policy_target_crn == null ? ibm_iam_authorization_policy.db2_s2s_policy_account_scope[0].id : null
}

output "db2_s2s_resource_id" {
  description = "Target Resource ID for the Service to Service policy for DB2 instance"
  value       = var.db2_s2s_policy_target_crn != null ? module.crn_parser_db2_instance_crn[0].service_instance : null
}
