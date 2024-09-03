#!/bin/bash

export TF_VAR_ibmcloud_api_key="${VB_PRIVATE_APIKEY_TEST_STAGE}"
# export TF_VAR_prefix="test-vb-ease"
export TF_VAR_region="us-east"
export TF_VAR_resource_group="Default"
export TF_VAR_config_repo="https://github.com/vb-test-appflow-org/wasease_sample-getting-started-config_v0.1"
export TF_VAR_source_repo="https://github.com/vb-test-appflow-org/wasease-sample-getting-started_v0.1"
