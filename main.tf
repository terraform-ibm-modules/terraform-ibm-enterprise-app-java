locals {
  validate_config_repo = var.source_repo != null && var.config_repo == null ? tobool("Configuration repo URL is required in addition to the source repo URL.") : true
  validate_source_repo = var.source_repo == null && var.config_repo != null ? tobool("Source repo URL is required in addition to the configuration repo URL.") : true
  parameters           = var.source_repo == null && var.config_repo == null ? null : { "sourceRepoURL" : var.source_repo, "configRepoURL" : var.config_repo }
}

resource "ibm_resource_instance" "ease_instance" {
  name              = var.ease_name
  resource_group_id = var.resource_group_id
  service           = "ease"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters        = local.parameters
}
