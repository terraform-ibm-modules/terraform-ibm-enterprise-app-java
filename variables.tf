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
}

variable "tags" {
  type        = list(string)
  description = "Metadata labels describing the service instance, i.e. test"
  default     = []
}

variable "plan" {
  type        = string
  description = "The desired pricing plan for Enterprise Application Service instance."
  default     = "free"
  validation {
    condition     = contains(["trial", "standard", "free", "staging"], var.plan)
    error_message = "The only values accepted for the plan field are free, standard, staging and trial."
  }
}

variable "region" {
  type        = string
  description = "The desired region for deploying Enterprise Application Service instance."
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
  description = "The GitHub token to read from the application and configuration repos. It cannot be null if var.source_repo and var.config_repo are not null."
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
  nullable    = false
  sensitive   = true
}
