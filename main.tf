locals {
  # repository parameters are optional. If one of them is present, all (source and config repos and github token) must be filled
  validate_ease_repos_condition = !((var.source_repo == null && var.config_repo == null && var.repos_git_token == null) || (var.source_repo != null && var.config_repo != null && var.repos_git_token != null))
  validate_ease_repos_msg       = "If one of var.source_repo, var.config_repo and var.repos_git_token input parameters is not null all of them must be assigned with a value. Please check your input."
  # tflint-ignore: terraform_unused_declarations
  validate_ease_repos_chk = regex(
    "^${local.validate_ease_repos_msg}$",
    (!local.validate_ease_repos_condition
      ? local.validate_ease_repos_msg
  : ""))

  # source repo, config repo and gitToken will be set as input params to the service only if all of these parameters are set
  parameters = var.source_repo == null || var.config_repo == null || var.repos_git_token == null ? null : { "source_repo_url" : var.source_repo, "config_repo_url" : var.config_repo, "git_token" : var.repos_git_token }
}

resource "ibm_resource_instance" "ease_instance" {
  name              = var.ease_name
  resource_group_id = var.resource_group_id
  service           = "enterprise-app-java"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters        = local.parameters
}
