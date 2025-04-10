locals {
  sleep_create = "30s"
  prefix       = var.prefix != null ? (var.prefix != "" ? var.prefix : null) : null
}

########################################################################################################################
# Loading existing resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  existing_resource_group_name = var.existing_resource_group_name
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
  ease_name         = try("${local.prefix}-${var.instance_name}", var.instance_name)
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

# Define Service to Service (S2S) policy between Enterprise Application Service instance and MQ capacity instance

module "crn_parser_mq_capacity_instance_crn" {
  count   = var.mq_s2s_policy_target_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.mq_s2s_policy_target_crn
}

# reading the IAM account details from the provider to use when creating the S2S policies
data "ibm_iam_account_settings" "provider_account" {}

locals {
  # for S2S policy, the source accountID is the one owning the Enterprise Application Service instance and the target is the account retrieved from the MQ instance CRN or, if this is null, the one creating the policy and owning the Enterprise Application Service instance
  mq_s2s_subject_account_id = data.ibm_iam_account_settings.provider_account.account_id
  mq_s2s_target_account_id  = var.mq_s2s_policy_target_crn != null ? module.crn_parser_mq_capacity_instance_crn[0].account_id : data.ibm_iam_account_settings.provider_account.account_id
}

# creating S2S policy to MQ if enabled - MQ instance scope
resource "ibm_iam_authorization_policy" "mq_s2s_policy_crn_scope" {
  count = var.mq_s2s_policy_enable == true && var.mq_s2s_policy_target_crn != null ? 1 : 0
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

  # limiting the target accountID of S2S policy to the provider account ID
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

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = module.crn_parser_mq_capacity_instance_crn[0].service_instance
  }

}

# creating S2S policy to MQ if enabled - account scope scope
resource "ibm_iam_authorization_policy" "mq_s2s_policy_account_scope" {
  count = var.mq_s2s_policy_enable == true && var.mq_s2s_policy_target_crn == null ? 1 : 0
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

  # limiting the target accountID of S2S policy to the provider account ID
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

}

# Define Service to Service (S2S) policy between Enterprise Application Service instance and DB2 instance

# parsing secret crn to collect the DB2 instance ID and its owner account ID
module "crn_parser_db2_instance_crn" {
  count   = var.db2_s2s_policy_target_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.1.0"
  crn     = var.db2_s2s_policy_target_crn
}

locals {
  # for S2S policy, the source accountID is the one owning the Enterprise Application Service instance and the target is the account retrieved from the DB2 instance CRN or, if this is null, the one creating the policy and owning the Enterprise Application Service instance
  db2_s2s_subject_account_id = data.ibm_iam_account_settings.provider_account.account_id
  db2_s2s_target_account_id  = var.db2_s2s_policy_target_crn != null ? module.crn_parser_db2_instance_crn[0].account_id : data.ibm_iam_account_settings.provider_account.account_id
}

# creating S2S policy to DB2 if enabled - DB2 instance scope
resource "ibm_iam_authorization_policy" "db2_s2s_policy_crn_scope" {
  count = var.db2_s2s_policy_enable == true && var.db2_s2s_policy_target_crn != null ? 1 : 0
  roles = var.db2_s2s_policy_roles

  # limiting the source accountID of S2S policy to the provider account ID
  subject_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.db2_s2s_subject_account_id
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

  # limiting the target accountID of S2S policy to the provider account ID
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.db2_s2s_target_account_id
  }

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "dashdb-for-transactions"
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = module.crn_parser_db2_instance_crn[0].service_instance
  }
}

# creating S2S policy to DB2 if enabled - account scope
resource "ibm_iam_authorization_policy" "db2_s2s_policy_account_scope" {
  count = var.db2_s2s_policy_enable == true && var.db2_s2s_policy_target_crn == null ? 1 : 0
  roles = var.db2_s2s_policy_roles

  # limiting the source accountID of S2S policy to the provider account ID
  subject_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.db2_s2s_subject_account_id
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

  # limiting the target accountID of S2S policy to the provider account ID
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.db2_s2s_target_account_id
  }

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "dashdb-for-transactions"
  }

}
