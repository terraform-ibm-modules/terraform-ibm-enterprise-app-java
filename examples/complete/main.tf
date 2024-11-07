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

# parsing secret crn to collect the secrets manager ID, the region and the secret ID
module "crn_parser" {
  count   = var.repos_git_token_secret_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.repos_git_token_secret_crn
}

# setting the region for the provider on the secrets manager region
# if null it is left to empty string
locals {
  sm_region = var.repos_git_token_secret_crn != null ? module.crn_parser[0].region : ""
}

data "ibm_sm_arbitrary_secret" "sm_repo_github_token" {
  count       = var.repos_git_token_secret_crn != null ? 1 : 0
  instance_id = module.crn_parser[0].service_instance
  #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static type
  region    = module.crn_parser[0].region
  secret_id = module.crn_parser[0].resource
  provider  = ibm.ibm-sm
}

locals {
  repos_git_token = var.repos_git_token_secret_crn != null ? data.ibm_sm_arbitrary_secret.sm_repo_github_token[0].payload : null
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
