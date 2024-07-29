########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "basic"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

variable "liberty_aas_name" {
  type        = string
  description = "The name for the newly provisioned Open Liberty SaaS service instance."
  default     = "Liberty_aas_"
}

variable "source_repo_url" {
  type        = string
  description = "The URL for the Open Liberty SaaS application source code."
}

variable "config_repo_url" {
  type        = string
  description = "The URL for the Open Liberty SaaS application configuration code."
}
