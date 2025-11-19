########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API Key"
  sensitive   = true
}

variable "secrets_manager_ibmcloud_api_key" {
  type        = string
  description = "API key to authenticate on Secrets Manager instance. If null the ibmcloud_api_key will be used."
  default     = null
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to null or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."
  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. [Learn more](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui#create_rgs) about how to create a resource group."
  default     = "Default"
}

variable "instance_name" {
  type        = string
  description = "The name for the newly provisioned Enterprise Application Service instance. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "instance"
}

variable "plan" {
  type        = string
  description = "The desired pricing plan for Enterprise Application Service instance."
  default     = "standard"
  validation {
    # free plan is added only to allow test/validation execution (its catalog name is Trial, programmatic name is free)
    condition     = contains(["standard", "free"], var.plan)
    error_message = "The only values accepted for the plan field are standard and free."
  }
}

variable "region" {
  type        = string
  description = "The region to provision all resources in. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/region) about how to select different regions for different services."
  default     = "us-east"

  validation {
    condition     = contains(["us-east"], var.region)
    error_message = "Invalid value for `region` , valid values for Enterprise Application Service offering are: `us-east`"
  }
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
  validation {
    condition     = var.repos_git_token_secret_crn != null ? can(regex("^crn\\:v\\d(\\:[\\w\\-_]*){2}\\:secrets-manager\\:[\\w\\-_]*\\:([aos]\\/[\\w_\\-]+)?(\\:[\\w_\\-]*)\\:secret\\:[\\w\\-_]*", var.repos_git_token_secret_crn)) : true
    error_message = "The value for var.repos_git_token_secret_crn is not a valid CRN."
  }
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
  description = "ID of the subscription to use to create the Enterprise Application Service instance. Set to null to use the value from subscription_id_secret_crn."
  sensitive   = true
}

variable "subscription_id_secret_crn" {
  type        = string
  description = "The CRN of the existing secret storing on Secrets Manager the subscriptionID to use to create the Enterprise Application Service instance. Default to null."
  default     = null
  validation {
    condition     = var.subscription_id_secret_crn == null ? var.subscription_id != null : true
    error_message = "Input parameters subscription_id_secret_crn and subscription_id cannot be both null."
  }
  validation {
    condition     = var.subscription_id_secret_crn != null ? can(regex("^crn\\:v\\d(\\:[\\w\\-_]*){2}\\:secrets-manager\\:[\\w\\-_]*\\:([aos]\\/[\\w_\\-]+)?(\\:[\\w_\\-]*)\\:secret\\:[\\w\\-_]*", var.subscription_id_secret_crn)) : true
    error_message = "The value for var.subscription_id_secret_crn is not a valid CRN."
  }
}

###################################################
# MQ S2S policy definition
###################################################

variable "mq_s2s_policy_enable" {
  type        = bool
  description = "Flag to enable creation of the Service to Service policy to enable the Enterprise Application Service instance to reach MQ instance. Default to true."
  default     = true
}

variable "mq_s2s_policy_roles" {
  type        = list(string)
  description = "List of roles to be configured for the Service to Service policy to MQ. Default to Viewer role."
  default     = ["Viewer"]
  validation {
    condition = alltrue([
      for role in var.mq_s2s_policy_roles : contains(["Administrator", "Viewer", "Operator", "Editor"], role)
    ])
    error_message = "The values of var.mq_s2s_policy_roles must be one or more of \"Administrator\", \"Viewer\", \"Operator\", \"Editor\""
  }
}

variable "mq_capacity_s2s_policy_target_crn" {
  type        = string
  description = "MQ resource capacity instance CRN to restrict the target for the Service to Service policy to MQ service instance. If mq_s2s_policy_enable is true but this is null the S2S policy is created at account scope on Enterprise Application Service instance account owner. Default to null."
  default     = null
  validation {
    condition     = var.mq_capacity_s2s_policy_target_crn != null ? can(regex("^crn\\:v\\d(\\:[\\w\\-_]*){2}\\:mqcloud::[\\w\\-_]*):([aos]\\/[\\w_\\-]+)?(\\:[\\w_\\-]*){3}", var.mq_capacity_s2s_policy_target_crn)) : true
    error_message = "The value for var.mq_capacity_s2s_policy_target_crn is not a valid CRN."
  }
}

###################################################
# DB2 S2S policy definition
###################################################

variable "db2_s2s_policy_enable" {
  type        = bool
  description = "Flag to enable creation of the Service to Service policy to enable the Enterprise Application Service instance to reach DB2 instance. Default to true."
  default     = true
}

variable "db2_s2s_policy_roles" {
  type        = list(string)
  description = "List of roles to be configured for the Service to Service policy to DB2. Default to Viewer role."
  default     = ["Viewer"]
  validation {
    condition = alltrue([
      for role in var.db2_s2s_policy_roles : contains(["Administrator", "Viewer", "Operator", "Editor"], role)
    ])
    error_message = "The values of var.db2_s2s_policy_roles must be one or more of \"Administrator\", \"Viewer\", \"Operator\", \"Editor\""
  }
}

variable "db2_s2s_policy_target_crn" {
  type        = string
  description = "DB2 resource capacity instance CRN to restrict the target for the Service to Service policy to DB2 service instance. If db2_s2s_policy_enable is true but this is null the S2S policy is created at account scope on Enterprise Application Service instance account owner. Default to null."
  default     = null
  validation {
    condition     = var.db2_s2s_policy_target_crn != null ? can(regex("^crn\\:v\\d(\\:[\\w\\-_]*){2}\\:dashdb-for-transactions::[\\w\\-_]*):([aos]\\/[\\w_\\-]+)?(\\:[\\w_\\-]*){3}", var.db2_s2s_policy_target_crn)) : true
    error_message = "The value for var.db2_s2s_policy_target_crn is not a valid CRN."
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
