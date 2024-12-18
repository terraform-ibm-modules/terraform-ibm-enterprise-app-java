locals {

  # setting up parameters_json attribute value according to the input configuration

  # source repo, config repo and gitToken will be set as input params to the service only if all of these parameters are set
  git_parameters = var.source_repo == null || var.config_repo == null || var.repos_git_token == null ? null : { "source_repo_url" : var.source_repo, "config_repo_url" : var.config_repo, "git_token" : var.repos_git_token }

  maven_repository_parameters = var.source_repo_type == "maven" ? {
    "source_repo_type" : var.source_repo_type
    "source_repo_credentials" : {
      "username" : var.maven_repository_username
      "password" : var.maven_repository_password
    }
    } : {
    "source_repo_type" : var.source_repo_type
    "source_repo_credentials" : {
      "username" : ""
      "password" : ""
    }
  }

  # putting subscription_id, git parameters and maven repository parameters together
  parameters = merge({ "subscription_id" : var.subscription_id }, local.git_parameters, local.maven_repository_parameters)

}

resource "ibm_resource_instance" "ease_instance" {
  name              = var.ease_name
  resource_group_id = var.resource_group_id
  service           = "enterprise-app-java"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters_json   = jsonencode(local.parameters)
}
