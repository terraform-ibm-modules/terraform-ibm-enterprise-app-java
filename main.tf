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

  parameters = var.source_repo == null && var.config_repo == null ? null : { "sourceRepoURL" : var.source_repo, "configRepoURL" : var.config_repo }
}

resource "ibm_resource_instance" "ease_instance" {
  name              = var.ease_name
  resource_group_id = var.resource_group_id
  service           = "ease"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters        = local.parameters
}
