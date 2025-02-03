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
  description = "Prefix to add to all resources created by this deployable architecture . To not use any prefix value, you can set this value to `null` or an empty string."
  default     = "dev"
}

variable "use_existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable value"
}

variable "ease_name" {
  type        = string
  description = "The name for the newly provisioned Enterprise Application Service instance."
  default     = "instance"
}

variable "plan" {
  type        = string
  description = "The desired pricing plan for IBM Enterprise Application Service instance."
  default     = "standard"
  validation {
    # free plan is added only to allow test/validation execution (its catalog name is Trial)
    condition     = contains(["standard", "free"], var.plan)
    error_message = "The only values accepted for the plan field are standard and free."
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

# github token configuration - the token or the CRN of the existing secret on a Secrets Manager instance
# if both are present the secret from Secrets Manager has higher priority

variable "repos_git_token_secret_crn" {
  type        = string
  description = "The CRN of the existing secret storing on Secrets Manager the GitHub token to read from the application and configuration repositories."
  default     = null
}

variable "repos_git_token" {
  type        = string
  description = "The GitHub token to read from the application and configuration repositories. If `repos_git_token_secret_crn` is not null, `repos_git_token` is not used."
  default     = null
  sensitive   = true
}

# subscriptionID to create the Enterprise Application Service instance
# it is possible to set directly the subscription_id value or the CRN of the existing secret on a Secrets Manager instance
# if both are present the secret from Secrets Manager has higher priority

variable "subscription_id" {
  type        = string
  description = "ID of the subscription to use to create the Enterprise Application Service instance."
  default     = null
  sensitive   = true
}

variable "subscription_id_secret_crn" {
  type        = string
  description = "The CRN of the existing secret storing on Secrets Manager the subscriptionID to use to create the Enterprise Application Service instance."
  default     = null
  validation {
    condition     = var.subscription_id_secret_crn == null ? var.subscription_id != null : true
    error_message = "Input parameters subscription_id_secret_crn and subscription_id cannot be both null."
  }
}

###################################################
# MQ S2S policy definition
###################################################

variable "mq_s2s_policy_enable" {
  type        = bool
  description = "Flag to enable creation of the Service to Service policy to enable the Enterprise Application Service instance to reach MQ instance. Default to false."
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

variable "mq_s2s_policy_target_resource_id" {
  type        = string
  description = "MQ resource instance ID to set as target for the Service to Service policy. Default to null."
  default     = null
  validation {
    condition     = var.mq_s2s_policy_enable == true ? var.mq_s2s_policy_target_resource_id != null : true
    error_message = "If var.mq_s2s_policy_enable is true the MQ instance ID to set as target of Service to Service policy cannot be null."
  }
}

###################################################
# Deploy and Run use-case specific parameters
###################################################

# repository input variables validation
variable "source_repo_type" {
  type        = string
  description = "Type of the source code repository. For GitHub source repository (Build Deploy and Run use-case) use `git` as value. For Deploy and Run use-case through a maven repository use value `maven`. Default value set to git."
  default     = "git"
  nullable    = false
  validation {
    condition     = var.source_repo_type == "maven" || var.source_repo_type == "git"
    error_message = "maven or git are the only allowed values for var.source_repo_type"
  }
}

variable "maven_repository_username" {
  type        = string
  default     = null
  description = "Maven repository authentication username if needed. Default to null."
}

variable "maven_repository_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "Maven repository authentication password if needed. Default to null."
}
