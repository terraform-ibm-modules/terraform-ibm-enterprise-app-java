resource "ibm_resource_instance" "liberty_aas_instance" {
  name              = var.liberty_aas_name
  resource_group_id = var.ibm_resource_group_id
  service           = "appengine"
  plan              = "free"
  location          = "global"
  tags              = var.tags
}
