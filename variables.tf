########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group to use for the creation of the Enterprise Application Service instance (https://test.cloud.ibm.com/account/resource-groups)."
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

variable "plan" {
  type        = string
  description = "The desired pricing plan for IBM Enterprise Application Service instance."
  default     = "free"
}

variable "region" {
  type        = string
  description = "The desired region for deploying IBM Enterprise Application Service instance."
  default     = "us-east"
}

variable "source_repo" {
  type        = string
  description = "The URL for the repository storing the source code of the application to deploy through IBM Cloud Enterprise Application Service."
  default     = null
}

variable "config_repo" {
  type        = string
  description = "The URL for the repository storing the configuration to use for the application to deploy through IBM Cloud Enterprise Application Service."
  default     = null
}

variable "repos_git_token" {
  type        = string
  description = "The GitHub token to read from the application and configuration repos. It is needed only for private repositories, for public ones leave to default null value."
  default     = null
  sensitive   = true
}
