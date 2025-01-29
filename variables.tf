########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group to use for the creation of the Enterprise Application Service instance."
}

variable "ease_name" {
  type        = string
  description = "The name for the newly provisioned Enterprise Application Service instance."
  default     = "instance"
}

variable "tags" {
  type        = list(string)
  description = "Metadata labels describing the service instance, i.e. test"
  default     = []
}

variable "plan" {
  type        = string
  description = "The desired pricing plan for Enterprise Application Service instance."
  default     = "standard"
  validation {
    # free plan is added only to allow test/validation execution (its catalog name is Trial)
    condition     = contains(["standard", "free"], var.plan)
    error_message = "The only values accepted for the plan field are standard and free."
  }
}

variable "region" {
  type        = string
  description = "The desired region for deploying Enterprise Application Service instance."
  default     = "us-east"
}

variable "source_repo" {
  type        = string
  description = "The URL for the repository storing the source code of the application or the URL of the Maven artifact repository storing the existing prebuilt archive (WAR or EAR) to deploy and run through Enterprise Application Service on IBM Cloud."
  default     = null
}

variable "config_repo" {
  type        = string
  description = "The URL for the repository storing the configuration to use for the application to run through Enterprise Application Service on IBM Cloud."
  default     = null
}

variable "repos_git_token" {
  type        = string
  description = "The GitHub token to read from the application and configuration repositories. It cannot be null if var.source_repo and var.config_repo are not null."
  default     = null
  sensitive   = true
  validation {
    condition     = var.repos_git_token != null ? (var.source_repo != null && var.config_repo != null) : (var.source_repo == null && var.config_repo == null)
    error_message = "If at least one of var.source_repo, var.config_repo, var.repos_git_token input parameters is not null all of them must be assigned with a value, but var.repos_git_token is null."
  }
}

variable "subscription_id" {
  type        = string
  description = "ID of the subscription to use to create the Enterprise Application Service instance."
  nullable    = true
  sensitive   = true
}

# maven repository specific input parameters

# maven repository input variables validation
variable "source_repo_type" {
  type        = string
  description = "Type of the source code repository. For maven source repository type, use value `maven`. Git for GitHub repository. Default value set to git."
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
