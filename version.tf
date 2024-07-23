terraform {
  required_version = ">= 1.5"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      ibmcloud_api_key = var.ibmcloud_api_key
      version = ">= 1.67.0"
    }
  }
}