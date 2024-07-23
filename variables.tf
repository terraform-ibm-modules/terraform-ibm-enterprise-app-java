########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IAM API Key for IBM Cloud access (https://test.cloud.ibm.com/iam/apikeys)."
  sensitive   = true
}

variable "ibm_resource_group_id" {
  description = "The ID of the resource group to use for the creation of the Open Liberty SaaS service instance (https://test.cloud.ibm.com/account/resource-groups)."
  default = null
}

variable "liberty_aas_name" {
  description = "The name for the newly provisioned Open Liberty SaaS service instance."
}

variable "source_repo_url" {
  description = "The URL for the Open Liberty SaaS application source code."
}

variable "config_repo_url" {
  description = "The URL for the Open Liberty SaaS application configuration code."
}
