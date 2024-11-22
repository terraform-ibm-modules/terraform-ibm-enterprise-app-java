########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Reading the subscriptionID value from the existing Secrets Manager instance
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
  sm_region = var.subscription_id_secret_crn != null ? module.crn_parser_subid[0].region : ""
}

data "ibm_sm_arbitrary_secret" "sm_subscription_id" {
  count       = var.subscription_id_secret_crn != null ? 1 : 0
  instance_id = module.crn_parser_subid[0].service_instance
  #checkov:skip=CKV_SECRET_6: does not require high entropy string as is static type
  region    = module.crn_parser_subid[0].region
  secret_id = module.crn_parser_subid[0].resource
  provider  = ibm.ibm-sm
}

########################################################################################################################
# Enterprise Application Service Instance
########################################################################################################################

module "ease" {
  source            = "../../"
  ease_name         = var.prefix
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags
  plan              = var.plan
  region            = var.region
  subscription_id   = data.ibm_sm_arbitrary_secret.sm_subscription_id[0].payload
}
