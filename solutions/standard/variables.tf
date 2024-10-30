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
  description = "Prefix to append to all resources created by this deployable architecture"
  default     = "ease-da"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable value"
  default     = null
}

variable "plan" {
  type        = string
  description = "The desired pricing plan for IBM Enterprise Application Service instance."
  default     = "free"
  validation {
    condition     = contains(["trial", "standard", "free", "staging"], var.plan)
    error_message = "The only values accepted for the plan field are free, standard, staging and trial."
  }
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

# github token configuration - the token or the tuple secrets manager id, secrets manager region and secret id are alternative
# if both are present the tuple for secrets manager has higher priority

variable "repos_git_token_existing_secrets_manager_id" {
  type        = string
  description = "The existing Secrets Manager instance to retrieve the GitHub token value. If not null, var.repos_git_token value will be ignored."
  default     = null
}

variable "repos_git_token_existing_secrets_manager_region" {
  type        = string
  description = "The existing Secrets Manager instance region to retrieve the GitHub token value."
  default     = "us-south"
}

variable "repos_git_token_secret_id" {
  type        = string
  description = "The secretID where the value for the GitHub token is stored in the existing Secrets Manager instance."
  default     = null
}

variable "repos_git_token" {
  type        = string
  description = "The GitHub token to read from the application and configuration repos. If var.repos_git_token_existing_secrets_manager_id is not null, var.repos_git_token is not used."
  default     = null
  sensitive   = true
}

###################################################
# MQ S2S policy definition
###################################################

variable "mq_s2s_policy_enable" {
  type        = bool
  description = "Flag to enable creation of the Service to Service policy to enable the Enterprise Application Service instance to reach MQ instance. Default to false"
  default     = false
}

variable "mq_s2s_policy_roles" {
  type        = list(string)
  description = "List of roles to be configured for the Service to Service policy. Default to Viewer role."
  default     = ["Viewer"]
  validation {
    condition = alltrue([
      for role in var.mq_s2s_policy_roles : contains(["Administrator", "Viewer", "Operator", "Editor"], role)
    ])
    error_message = "The values of var.mq_s2s_policy_roles must be one or more of \"Administrator\", \"Viewer\", \"Operator\", \"Editor\""
  }
}

variable "mq_s2s_policy_source_account_id" {
  type        = string
  description = "Source accountID for the Service to Service policy from the Enterprise Application Service instance to MQ instance. If mq_s2s_policy_enable is true and this is left to null the accountID of the API key configured for the provider is used"
  default     = null
}

variable "mq_s2s_policy_target_account_id" {
  type        = string
  description = "Target accountID for the Service to Service policy from the Enterprise Application Service instance to MQ instance. If mq_s2s_policy_enable is true and this is left to null the accountID of the API key configured for the provider is used"
  default     = null
}

variable "mq_s2s_policy_limit_source_resource_flag" {
  type        = bool
  description = "Flag to limit the source of the Service to Service policy to the created Enterprise Application Service resource instance ID. If false the Service to Service policy source scope is not limited to the resource instance ID. Configuring scope on the resource instance ID and on the resource group ID is mutually exclusive."
  default     = true
}

variable "mq_s2s_policy_limit_source_resource_group_flag" {
  type        = bool
  description = "Flag to limit the source of the Service to Service policy to the created Resource Group ID. If false the Service to Service policy source scope is not limited to the resource group ID. Configuring scope on the resource instance ID and on the resource group ID is mutually exclusive."
  default     = false
}

variable "mq_s2s_policy_limit_target_resource_id" {
  type        = string
  description = "Flag to limit the target of the Service to Service policy to a specific MQ resource instance ID. If null the Service to Service policy target scope is not limited to the resource instance ID"
  default     = null
}

variable "mq_s2s_policy_limit_target_resource_group_id" {
  type        = string
  description = "Flag to limit the target of the Service to Service policy to a specific resource group ID. If null the Service to Service policy target scope is not limited to the resource group ID"
  default     = null
}
