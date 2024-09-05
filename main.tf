locals {
  # repository parameters are optional. If one of them is present, both must be filled
  validate_ease_repos_condition = ((var.source_repo != null || length(var.source_repo) > 0) && (var.config_repo == null || length(var.config_repo) == 0)) || ((var.source_repo == null || length(var.source_repo) == 0) && (var.config_repo != null || length(var.config_repo) > 0))
  validate_ease_repos_msg       = "If one of var.source_repo or var.config_repo input parameters is not null both of them must be assigned with a value. Please check your input."
  # tflint-ignore: terraform_unused_declarations
  validate_ease_repos_chk = regex(
    "^${local.validate_ease_repos_msg}$",
    (!local.validate_ease_repos_condition
      ? local.validate_ease_repos_msg
  : ""))

  # source and config repos, and gitToken will be set as parameters input param to the service only if both source and config repos are filled
  parameters = var.source_repo == null || var.config_repo == null ? null : { "sourceRepoURL" : var.source_repo, "configRepoURL" : var.config_repo }
  # token parameter is added only if not null
  parameters_final = var.source_repo == null && var.config_repo == null && var.repos_git_token != null ? merge(local.parameters, { "gitToken" : var.repos_git_token }) : local.parameters
}

resource "ibm_resource_instance" "ease_instance" {
  name              = var.ease_name
  resource_group_id = var.resource_group_id
  service           = "ease"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters        = local.parameters_final
}
