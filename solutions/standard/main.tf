locals {
  sleep_create = "30s"
  prefix       = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null
}

########################################################################################################################
# Resource group management
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.use_existing_resource_group == false ? try("${local.prefix}-${var.resource_group_name}", var.resource_group_name) : null
  existing_resource_group_name = var.use_existing_resource_group == true ? var.resource_group_name : null
}

########################################################################################################################
# Identify the GitHub token to use:
# - if var.repos_git_token_secret_crn is not null its value is used
# - if var.var.repos_git_token_secret_crn is null and var.repos_git_token is not null, var.repos_git_token value is used
# - if both var.repos_git_token_secret_crn and var.repos_git_token are null, the token is null
########################################################################################################################

# parsing secret crn to collect the secrets manager ID, the region and the secret ID
module "crn_parser_token" {
  count   = var.repos_git_token_secret_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
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
  repos_git_token = var.repos_git_token_secret_crn != null ? data.ibm_sm_arbitrary_secret.sm_repo_github_token[0].payload : (var.repos_git_token == null ? null : var.repos_git_token)
}

########################################################################################################################
# Identify the subscriptionID to use:
# - if var.subscription_id_secret_crn is not null its value is used
# - if var.subscription_id_secret_crn is null and var.subscription_id is not null, var.subscription_id value is used
# - if both var.subscription_id_secret_crn and var.subscription_id are null, the value is null
########################################################################################################################

# parsing secret crn to collect the secrets manager ID, the region and the secret ID
module "crn_parser_subid" {
  count   = var.subscription_id_secret_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.subscription_id_secret_crn
}

# setting the region for the provider on the secrets manager region
# if null it is left to empty string
locals {
  sm_region = var.subscription_id_secret_crn != null ? module.crn_parser_subid[0].region : (var.repos_git_token_secret_crn != null ? module.crn_parser_token[0].region : "")
}

data "ibm_sm_arbitrary_secret" "sm_subscription_id" {
  count       = var.subscription_id_secret_crn != null ? 1 : 0
  instance_id = module.crn_parser_subid[0].service_instance
  #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static type
  region    = module.crn_parser_subid[0].region
  secret_id = module.crn_parser_subid[0].resource
  provider  = ibm.ibm-sm
}

locals {
  subscription_id = var.subscription_id_secret_crn != null ? data.ibm_sm_arbitrary_secret.sm_subscription_id[0].payload : (var.subscription_id == null ? null : var.subscription_id)
}

########################################################################################################################
# Enterprise Application Service Instance deployment
########################################################################################################################

module "ease" {
  source            = "../../"
  ease_name         = try("${var.prefix}-${var.ease_name}", var.ease_name)
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags
  plan              = var.plan
  region            = var.region
  config_repo       = var.config_repo
  source_repo       = var.source_repo
  repos_git_token   = local.repos_git_token
  subscription_id   = local.subscription_id
  # Deploy and Run specific use-case inputs
  source_repo_type          = var.source_repo_type
  maven_repository_username = var.maven_repository_username
  maven_repository_password = var.maven_repository_password
}

locals {
  # collecting the dashboard_url from the resource creation output as it is not returned when reading using the datasource
  app_dashboard_url = module.ease.ease_instance.dashboard_url
}

# wait for asynch tasks to be performed before loading the resource instance details to output
resource "time_sleep" "wait_deployment" {
  depends_on      = [module.ease]
  create_duration = local.sleep_create
}

data "ibm_resource_instance" "ease_resource" {
  depends_on = [time_sleep.wait_deployment]
  identifier = module.ease.ease_instance.id
}

# Definining Service to Service (S2S) policy between Enterprise Application Service instance and MQ capacity instance

# reading the IAM account details from the provider
data "ibm_iam_account_settings" "provider_account" {}

locals {
  # for S2S policy, the source accountID is the one owning the ease instance and the target is the account creating the policy, so in this case are the same account
  mq_s2s_subject_account_id = data.ibm_iam_account_settings.provider_account.account_id
  mq_s2s_target_account_id  = data.ibm_iam_account_settings.provider_account.account_id
}

# creating S2S policy if enabled
resource "ibm_iam_authorization_policy" "policy" {
  count = var.mq_s2s_policy_enable == true ? 1 : 0
  roles = var.mq_s2s_policy_roles

  # limiting the source accountID of S2S policy to the provider account ID is used
  subject_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.mq_s2s_subject_account_id
  }

  subject_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "enterprise-app-java"
  }

  # limiting the target serviceInstance of S2S policy to the Enterprise Application Service instance ID
  subject_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = module.ease.ease_instance.guid
  }

  # limiting the target accountID of S2S policy to the provider account ID is used
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.mq_s2s_target_account_id
  }

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "mqcloud"
  }

  # limiting the target serviceInstance of S2S policy to the MQ instance ID
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = var.mq_s2s_policy_target_resource_id
  }

}
