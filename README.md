<!-- Update this title with a descriptive name. Use sentence case. -->
# Enterprise Application Service for Java (also know as EASeJava)

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

Use this module to provision and configure an [Enterprise Application Service](https://cloud.ibm.com/catalog/services/enterprise-application-service) instance on IBM Cloud.


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

This module has the following prerequisites as mandatory input parameters:

1. The IBM Cloud API Key (https://cloud.ibm.com/iam/apikeys) for the account where to deploy the Enterprise Application Service instance
1. Resource Group ID (https://cloud.ibm.com/account/resource-groups) containing the Enterprise Application Service instance

Optionally, the following optional input parameters are required in order to pre-configure the Enterprise Application Service instance:

1. URL of the repository storing the Java liberty application source code to build in the Enterprise Application Service instance
1. URL of the repository storing the Java liberty application configuration to build in the Enterprise Application Service instance
1. GitHub token with read access to the source code and to the configuration repositories.

**Note:** all these parameters are mandatory in the case any of them is different than their default null value, with the GitHub token mandatory also if the source code and the configuration repositories are both public.

In the case the source code and the configuration repositories are not set at Enterprise Application Service instance deployment time, it will be possible to configure them through the Enterprise Application Service dashboard url that will be included in the `ease_instance` output details of this module.

In both the cases (pre-configure the Enterprise Application Service instance at deployment time or configure it through its dashboard when the instance deployment is complete), the repositories must satisfy a further prerequisite as described [here](#ibm-appflow-github-application-prerequisite)

#### IBM AppFlow GitHub application prerequisite

In order to configure the Enterprise Application Service instance to build the Java liberty application using the source code and the configuration repositories, the GitHub application **IBM AppFlow** must installed in the GitHub organization(s) hosting the repositories and enable to access both of them.

To install and configure the **IBM AppFlow** GitHub application refer to https://github.com/apps/ibm-enterprise-application-service

**Note:** in the case you need to configure an Enterprise Application Service instance in an environment different from IBM Cloud public platform, you need to install and configure a specific version of the **IBM AppFlow** GitHub application.

### Java liberty sample application
For an example of source code and configuration repositories to build in an Enterprise Application Service instance you can fork the repositories below:

- source code repository: https://github.com/IBMAppFlowTest/sample-getting-started

- configuration repository: https://github.com/IBMAppFlowTest/sample-getting-started-config

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
  # Replace "master" with a GIT release version to lock into a specific release
  source           = "git::https://github.com/terraform-ibm-modules/terraform-ibm-enterprise-app-java.git?ref=master"
  ease_name         = "your-ease-app-name"
  resource_group_id = module.resource_group.resource_group_id
  tags              = var.resource_tags
  plan              = var.plan
  region            = var.region
  config_repo       = var.config_repo
  source_repo       = var.source_repo
  repos_git_token   = var.repos_git_token <!-- pragma: allowlist secret -->
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
| <a name="input_plan"></a> [plan](#input\_plan) | The desired pricing plan for Enterprise Application Service instance. | `string` | `"standard"` | no |
| <a name="input_region"></a> [region](#input\_region) | The desired region for deploying Enterprise Application Service instance. | `string` | `"us-east"` | no |
| <a name="input_repos_git_token"></a> [repos\_git\_token](#input\_repos\_git\_token) | The GitHub token to read from the application and configuration repos. It cannot be null if var.source\_repo and var.config\_repo are not null. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use for the creation of the Enterprise Application Service instance. | `string` | n/a | yes |
| <a name="input_source_repo"></a> [source\_repo](#input\_source\_repo) | The URL for the repository storing the source code of the application to deploy through IBM Cloud Enterprise Application Service. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | ID of the subscription to use to create the Enterprise Application Service instance. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Metadata labels describing the service instance, i.e. test | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_ease_instance"></a> [ease\_instance](#output\_ease\_instance) | Enterprise Application Service instance details |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
