########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group that contains the Enterprise Application Service instance."
}

variable "ease_name" {
  type        = string
  description = "The name of the Enterprise Application Service instance to create. If a `prefix` input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  default     = "instance"
}

variable "tags" {
  type        = list(string)
  description = "Metadata labels that describe the Enterprise Application Service instance, i.e. `test`."
  default     = []
}

variable "plan" {
  type        = string
  description = "The pricing plan for the Enterprise Application Service instance. Possible values are `standard` and `free`."
  default     = "standard"
  validation {
    # free plan is added only to allow test/validation execution (its catalog name is Trial)
    condition     = contains(["standard", "free"], var.plan)
    error_message = "The value is not valid. Possible values are `standard` and `free`."
  }
}

variable "region" {
  type        = string
  description = "The region where the Enterprise Application Service instance is created."
  default     = "us-east"
}

variable "source_repo" {
  type        = string
  description = "The URL for the GitHub repository that contains the source code, or the URL of the Maven artifact repository that contains enterprise archive (EAR) or web archive (WAR) files for the application to deploy and run through Enterprise Application Service on IBM Cloud."
  default     = null
}

variable "config_repo" {
  type        = string
  description = "The URL for the repository that contains the configuration of the application to run through Enterprise Application Service on IBM Cloud."
  default     = null
}

variable "repos_git_token" {
  type        = string
  description = "The GitHub token to read from the application and configuration repositories. This variable must be consistently set with `var.source_repo` and `var.config_repo`. All of these variables must be set to `null` or they must all be set to valid values."
  default     = null
  sensitive   = true
  validation {
    condition     = var.repos_git_token != null ? (var.source_repo != null && var.config_repo != null) : (var.source_repo == null && var.config_repo == null)
    error_message = "To maintain proper access to the application and configuration repositories, `var.repos_git_token` must be set along with `var.source_repo` and `var.config_repo`. All of these variables must be set to `null`, or they must all be set to valid values."
  }
}

variable "subscription_id" {
  type        = string
  description = "ID of the subscription to use to create the Enterprise Application Service instance."
  nullable    = false
  sensitive   = true
}

# maven repository specific input parameters

# maven repository input variables validation
variable "source_repo_type" {
  type        = string
  description = "Type of the source code repository. Possible values are `maven` for Maven repository types and `git` for GitHub repository types. Default value is `git`."
  default     = "git"
  nullable    = false
  validation {
    condition     = var.source_repo_type == "maven" || var.source_repo_type == "git"
    error_message = "The value is not valid. Possible values are `maven` or `git`."
  }
}

variable "maven_repository_username" {
  type        = string
  default     = null
  description = "Username to authenticate with a Maven repository, if applicable. Default value is `null`."
}

variable "maven_repository_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "Password to authenticate with a Maven repository, if applicable. Default value is `null`."
}
