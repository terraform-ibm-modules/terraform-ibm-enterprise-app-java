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

# as the EASeJava app deployment expects some asynch tasks to be performed we wait for a configured interval before loading the resource instance details
resource "time_sleep" "wait_deployment" {
  depends_on      = [module.ease]
  create_duration = local.sleep_create
}

data "ibm_resource_instance" "ease_resource" {
  depends_on = [time_sleep.wait_deployment]
  identifier = module.ease.ease_instance.id
}
