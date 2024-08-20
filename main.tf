resource "ibm_resource_instance" "ease_instance" {
  name              = var.ease_name
  resource_group_id = var.resource_group_id
  service           = "ease"
  plan              = "free"
  location          = "us-east"
  tags              = var.tags
  parameters        = jsonencode(var.parameters)
}
