########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group to use for the creation of the Enterprise Applicaiton Service instance (https://test.cloud.ibm.com/account/resource-groups)."
}

variable "ease_name" {
  type        = string
  description = "The name for the newly provisioned Enterprise Application Service instance."
}

variable "tags" {
  type        = list(string)
  description = "Metadata labels describing the service instance, i.e. test"
  default     = []
}

variable "source_repo" {
  type        = string
  description = "The URL for the Enterprise Application Service source code."
  default     = null
}

variable "config_repo" {
  type        = string
  description = "The URL for the Enterprise Application Service configuration code."
  default     = null
}
