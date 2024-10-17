locals {
  sleep_create = "30s"
}

########################################################################################################################
# Resource group management
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Reading the GitHub token from the existing Secrets Manager instance
########################################################################################################################

locals {

  # validating input parameters for existing secrets manager and the related secret id

  # validation for secrets manager region to be set for existing secrets manager instance
  validate_sm_region_cnd = var.repos_git_token_existing_secrets_manager_id != null && var.repos_git_token_existing_secrets_manager_region == null
  validate_sm_region_msg = "repos_git_token_existing_secrets_manager_region must also be set when value given for repos_git_token_existing_secrets_manager_id."
  # tflint-ignore: terraform_unused_declarations
  validate_sm_region_chk = regex(
    "^${local.validate_sm_region_msg}$",
    (!local.validate_sm_region_cnd
      ? local.validate_sm_region_msg
  : ""))

  # validation for repos_git_token_existing_secrets_manager_id to be set for existing secrets manager instance if repos_git_token_secret_id is set, and viceversa
  validate_sm_id_cnd = (var.repos_git_token_secret_id != null && var.repos_git_token_existing_secrets_manager_id == null || var.repos_git_token_secret_id == null && var.repos_git_token_existing_secrets_manager_id != null)
  validate_sm_id_msg = "repos_git_token_existing_secrets_manager_id and repos_git_token_secret_id must bet set both with a value if any of them is not null."
  # tflint-ignore: terraform_unused_declarations
  validate_sm_id_chk = regex(
    "^${local.validate_sm_id_msg}$",
    (!local.validate_sm_id_cnd
      ? local.validate_sm_id_msg
  : ""))

}

data "ibm_sm_arbitrary_secret" "repo_github_token" {
  count       = var.repos_git_token_existing_secrets_manager_id != null ? 1 : 0
  instance_id = var.repos_git_token_existing_secrets_manager_id
  #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static type
  region    = var.repos_git_token_existing_secrets_manager_region
  secret_id = var.repos_git_token_secret_id
  provider  = ibm.ibm-sm
}

locals {
  repos_git_token = var.repos_git_token_existing_secrets_manager_id != null ? data.ibm_sm_arbitrary_secret.repo_github_token[0].payload : null
}

########################################################################################################################
# Enterprise Application Service Instance deployment
########################################################################################################################

module "ease" {
  source            = "../../"
  ease_name         = "${var.prefix}-app"
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags
  plan              = var.plan
  region            = var.region
  config_repo       = var.config_repo
  source_repo       = var.source_repo
  repos_git_token   = local.repos_git_token
}

locals {
  # collecting the dashboard_url from the resource creation output as it is not returned when reading using the datasource
  app_dashboard_url = module.ease.ease_instance.dashboard_url
}

# as the EASeJava app deployment expects some asynch tasks to be performed we wait for a configured interval before loading the resource instance details
resource "time_sleep" "wait_deployment" {
  depends_on      = [module.ease]
  create_duration = local.sleep_create
}

data "ibm_resource_instance" "ease_resource" {
  depends_on = [time_sleep.wait_deployment]
  identifier = module.ease.ease_instance.id
}
