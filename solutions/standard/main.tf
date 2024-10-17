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
  repos_git_token   = var.repos_git_token
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

  # validation of var.mq_s2s_policy_limit_source_resource_group_flag and var.mq_s2s_policy_limit_source_resource_group_flag that cannot be both true at the same time
  validate_s2s_source_policy_flags_cnd = var.mq_s2s_policy_limit_source_resource_flag == true && var.mq_s2s_policy_limit_source_resource_group_flag == true
  validate_s2s_source_policy_flags_msg = "Setting Service to Service policy source scope on resource instance or on resource group is mutually exclusive. So var.mq_s2s_policy_limit_source_resource_group_flag and var.mq_s2s_policy_limit_source_resource_group_flag cannot be both true."
  # tflint-ignore: terraform_unused_declarations
  validate_s2s_source_policy_flags_chk = regex(
    "^${local.validate_s2s_source_policy_flags_msg}$",
    (!local.validate_s2s_source_policy_flags_cnd
      ? local.validate_s2s_source_policy_flags_msg
  : ""))

  # if the source and target account ID for the S2S policy are not specified in input vars the account ID of the provider will be used
  mq_s2s_subject_account_id = var.mq_s2s_policy_source_account_id == null ? data.ibm_iam_account_settings.provider_account.account_id : var.mq_s2s_policy_source_account_id
  mq_s2s_target_account_id  = var.mq_s2s_policy_target_account_id == null ? data.ibm_iam_account_settings.provider_account.account_id : var.mq_s2s_policy_target_account_id

}

# creating S2S policy if enabled
resource "ibm_iam_authorization_policy" "policy" {
  count = var.mq_s2s_policy_enable == true ? 1 : 0
  roles = var.mq_s2s_policy_roles

  # limiting the source accountID of S2S policy to the input var.mq_s2s_policy_source_account_id. If it is null the provider account ID is used
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

  # limiting the target serviceInstance of S2S policy to the Enterprise Application Service instance ID only if var.mq_s2s_policy_limit_source_resource_flag is true
  dynamic "subject_attributes" {
    for_each = var.mq_s2s_policy_limit_source_resource_flag == true ? [module.ease.ease_instance.guid] : []
    content {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = subject_attributes.value
    }
  }

  # limiting the source resourceGroupId of S2S policy to the resource group where the Enterprise Application Service instance ID is created only if var.mq_s2s_policy_limit_source_resource_group_flag is true
  dynamic "subject_attributes" {
    for_each = var.mq_s2s_policy_limit_source_resource_group_flag == true ? [module.resource_group.resource_group_id] : []
    content {
      name     = "resourceGroupId"
      operator = "stringEquals"
      value    = subject_attributes.value
    }
  }

  # limiting the target accountID of S2S policy to the input var.mq_s2s_policy_target_account_id. If it is null the provider account ID is used
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

  # limiting the target serviceInstance of S2S policy to the MQ instance ID only if var.mq_s2s_policy_limit_target_resource_id is not null
  dynamic "resource_attributes" {
    for_each = var.mq_s2s_policy_limit_target_resource_id != null ? [var.mq_s2s_policy_limit_target_resource_id] : []
    content {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = resource_attributes.value
    }
  }

  # limiting the target resourceGroupId of S2S policy to var.mq_s2s_policy_limit_target_resource_group_id only if not null
  dynamic "resource_attributes" {
    for_each = var.mq_s2s_policy_limit_target_resource_group_id != null ? [var.mq_s2s_policy_limit_target_resource_group_id] : []
    content {
      name     = "resourceGroupId"
      operator = "stringEquals"
      value    = resource_attributes.value
    }
  }

}
