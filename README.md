<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM Enterprise Application Service for Java (EASeJava)

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-enterprise-app-java?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-enterprise-app-java/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

Use this module to provision and configure an IBM [Enterprise Application Service](https://test.cloud.ibm.com/catalog/services/ease).


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-enterprise-app-java](#terraform-ibm-enterprise-app-java)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->

## Prerequisites
Must have these created prior to using this terraform code:

1. IBM Cloud API Key (https://test.cloud.ibm.com/iam/apikeys)
2. Resource Group ID (https://test.cloud.ibm.com/account/resource-groups)

Optionally, the following are required if you want to configure the EASeJava instance:

1. Application source and application config repositories (for the EASeJava instance)
2. GitHub token with read access to the Source and Config repositories, if private. It can be empty for public repositories
3. GitHub Application currently called IBM Appflow Dev (https://github.com/apps/ibm-appflow-dev-ibm-cloud/installations/new) installed in the GitHub organization hosting source and application config repositories

**NOTE:** For example source and config repositories that can be forked, check the below repositories:

https://github.com/IBMAppFlowTest/sample-getting-started

https://github.com/IBMAppFlowTest/sample-getting-started-config

<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-enterprise-app-java

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" <!-- pragma: allowlist secret -->
}

module "ease_module" {
  source            = "terraform-ibm-modules/ease/ibm"
  version           = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  name              = "ease_XXX"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  tags              = []
  plan              = "free"
  region            = "us-east"
  source_repo       = "http://xxxxx"
  config_repo       = "http://xxxxx"
  repo_git_token    = "XXXXXXXX" <!-- pragma: allowlist secret -->
}
```



### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

You need the following permissions to run this module:

- IAM services
    - **enterprise-application-service** service
        - `Editor` platform access

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!--
No permissions are needed to run this module.
-->

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.67.0, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_resource_instance.ease_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_repo"></a> [config\_repo](#input\_config\_repo) | The URL for the repository storing the configuration to use for the application to deploy through IBM Cloud Enterprise Application Service. | `string` | `null` | no |
| <a name="input_ease_name"></a> [ease\_name](#input\_ease\_name) | The name for the newly provisioned Enterprise Application Service instance. | `string` | n/a | yes |
| <a name="input_plan"></a> [plan](#input\_plan) | The desired pricing plan for IBM Enterprise Application Service instance. | `string` | `"staging"` | no |
| <a name="input_region"></a> [region](#input\_region) | The desired region for deploying IBM Enterprise Application Service instance. | `string` | `"us-east"` | no |
| <a name="input_repos_git_token"></a> [repos\_git\_token](#input\_repos\_git\_token) | The GitHub token to read from the application and configuration repos. It is needed only for private repositories, for public ones leave to default null value. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use for the creation of the Enterprise Application Service instance (https://test.cloud.ibm.com/account/resource-groups). | `string` | n/a | yes |
| <a name="input_source_repo"></a> [source\_repo](#input\_source\_repo) | The URL for the repository storing the source code of the application to deploy through IBM Cloud Enterprise Application Service. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Metadata labels describing the service instance, i.e. test | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ease_instance"></a> [ease\_instance](#output\_ease\_instance) | Enterprise Application Service instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
