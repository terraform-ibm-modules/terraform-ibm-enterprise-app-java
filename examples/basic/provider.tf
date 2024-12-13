########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# setting the region for the provider on the secrets manager region using the subscriptionID secret crn
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = module.crn_parser_subid.region
  alias            = "ibm-sm"
}
