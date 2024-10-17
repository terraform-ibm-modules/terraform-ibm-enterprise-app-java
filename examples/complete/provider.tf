########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.repos_git_token_existing_secrets_manager_region
  alias            = "ibm-sm"
}
