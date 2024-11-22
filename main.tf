locals {
  # source repo, config repo and gitToken will be set as input params to the service only if all of these parameters are set
  git_parameters = var.source_repo == null || var.config_repo == null || var.repos_git_token == null ? null : { "source_repo_url" : var.source_repo, "config_repo_url" : var.config_repo, "git_token" : var.repos_git_token }

  # adding subscription_id parameter to the input parameters structure
  parameters = merge({ "subscription_id" : var.subscription_id }, local.git_parameters)

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
