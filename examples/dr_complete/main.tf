locals {
  sleep_create = "30s"
}

########################################################################################################################
# Resource group management
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Reading the GitHub token from the existing Secrets Manager instance
########################################################################################################################

# parsing secret crn to collect the secrets manager ID, the region and the secret ID
module "crn_parser_token" {
  count   = var.repos_git_token_secret_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.7"
  crn     = var.repos_git_token_secret_crn
}

data "ibm_sm_arbitrary_secret" "sm_repo_github_token" {
  count       = var.repos_git_token_secret_crn != null ? 1 : 0
  instance_id = module.crn_parser_token[0].service_instance
  #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static type
  region    = module.crn_parser_token[0].region
  secret_id = module.crn_parser_token[0].resource
  provider  = ibm.ibm-sm
}

locals {
  repos_git_token = var.repos_git_token_secret_crn != null ? data.ibm_sm_arbitrary_secret.sm_repo_github_token[0].payload : null
}

########################################################################################################################
# Reading the subscriptionID value from the existing Secrets Manager instance
########################################################################################################################

# parsing secret crn to collect the secrets manager ID, the region and the secret ID
module "crn_parser_subid" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.7"
  crn     = var.subscription_id_secret_crn
}

data "ibm_sm_arbitrary_secret" "sm_subscription_id" {
  instance_id = module.crn_parser_subid.service_instance
  #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static type
  region    = module.crn_parser_subid.region
  secret_id = module.crn_parser_subid.resource
  provider  = ibm.ibm-sm
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
  subscription_id   = data.ibm_sm_arbitrary_secret.sm_subscription_id.payload
  # deploy and run use-case specific inputs
  source_repo_type          = "maven"
  maven_repository_username = var.maven_repository_username
  maven_repository_password = var.maven_repository_password
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
