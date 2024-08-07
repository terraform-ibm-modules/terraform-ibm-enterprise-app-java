########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibm_resource_group_id" {
  type        = string
  description = "The ID of the resource group to use for the creation of the Open Liberty SaaS service instance (https://test.cloud.ibm.com/account/resource-groups)."
}

variable "liberty_aas_name" {
  type        = string
  description = "The name for the newly provisioned Open Liberty SaaS service instance."
}

variable "tags" {
  type        = list(string)
  description = "Metadata labels describing the service instance, i.e. test"
  default     = []
}
