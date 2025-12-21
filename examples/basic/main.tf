########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
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
# Enterprise Application Service Instance
########################################################################################################################

module "ease" {
  source            = "../../"
  ease_name         = var.prefix
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags
  plan              = var.plan
  region            = var.region
  subscription_id   = data.ibm_sm_arbitrary_secret.sm_subscription_id.payload
}
