########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "ease-complete"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
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

variable "repos_git_token_secret_crn" {
  type        = string
  description = "The CRN of the existing secret stored on Secrets Manager."
  default     = null
}

variable "subscription_id_secret_crn" {
  type        = string
  description = "ID of the subscription to use to create the Enterprise Application Service instance."
  sensitive   = true
  nullable    = false
}
