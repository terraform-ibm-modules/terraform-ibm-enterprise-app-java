<!-- Update this title with a descriptive name. Use sentence case. -->
# Enterprise Application Service for Java

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
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

Use this module to provision and configure an [Enterprise Application Service](https://cloud.ibm.com/catalog/services/enterprise-application-service) (also shorthened to EASeJava or simply to `ease`) instance on IBM Cloud.

For more information about the Enterprice Application Service product you can refer to the [product documentation](https://www.ibm.com/docs/en/ease?topic=overview)


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-enterprise-app-java](#terraform-ibm-enterprise-app-java)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Build, deploy and run complete example](./examples/bdr_complete)
    * [Deploy and run complete example](./examples/dr_complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->

## Enterprise Application Service use cases support

This module supports both the use cases provided by the Enterprise Application Service:
- **Deploy and Run your application** use case: you can provide your existing prebuilt enterprise archive (EAR) or web archive (WAR) file in a Maven artifact repository, the service will allow to deploy and to run it.
- **Build, deploy and run your application** use case: you can provide your application source code through its GitHub repository URL, the service will allow to build, deploy and then run it.

For more details about the two different use-cases and the input parameters to use please refer to the sections below.

### Mandatory input parameters for both the use cases

Both the use-cases supported by this module need you to specify the following parameters as mandatory inputs.

1. The IBM Cloud API Key (https://cloud.ibm.com/iam/apikeys) for the account where to deploy the Enterprise Application Service instance
1. Resource Group ID (https://cloud.ibm.com/account/resource-groups) containing the Enterprise Application Service instance

## Deploy and Run use case input parameters

The following optional input parameters are required in order to pre-configure the Enterprise Application Service instance for the Deploy and Run use case:

1. URL of the Maven artifact repository storing the existing prebuilt enterprise archive (EAR) or web archive (WAR) file to run in the Enterprise Application Service instance
   1. If your Maven artifact repository needs basic authentication, you can specify the username and password using the related input variables. If the repository doesn't need authentication, you can leave them to their default values.
2. URL of the GitHub repository storing the application deployment configuration to run in the Enterprise Application Service instance
3. GitHub token with read access to the configuration repository.

**Note:** all these parameters (excluding the Maven repository username and password) are mandatory in the case any of them is different than their default null value (the GitHub token is mandatory also if the configuration repository is public). When all of them are left to the default null value it will be possible to configure the instance with their values once the instance is successfully created, as describe [here](#create-an-enterprise-application-service-instance-without-setting-any-repository)

The GitHub configuration repository must satisfy a further prerequisite as described [here](#ibm-appflow-github-application-prerequisite)

For more details about this use-case please refer to the Enterprise Application Service product documentation section available [here](https://www.ibm.com/docs/en/ease?topic=deploy-run-your-application-option)

### Build, Deploy and Run use case input parameters

The following optional input parameters are required in order to pre-configure the Enterprise Application Service instance for the Build, deploy and run use case:

1. URL of the GitHub repository storing your application source code to Build, deploy and run in the Enterprise Application Service instance
1. URL of the GitHub repository storing your application configuration to Build, deploy and run in the Enterprise Application Service instance
1. GitHub token with read access the source code and configuration repositories.

**Note:** all these parameters are mandatory in the case any of them is different than their default null value (the GitHub token is mandatory also if both the repositories are public). When all of them are left to the default null value it will be possible to configure the instance with their values once the instance is successfully created, as describe [here](#create-an-enterprise-application-service-instance-without-setting-any-repository)

Both the repositories must satisfy a further prerequisite as described [here](#ibm-appflow-github-application-prerequisite)

For more details about this use-case please refer to the Enterprise Application Service product documentation section available [here](https://www.ibm.com/docs/en/ease?topic=build-deploy-run-your-application-option)

#### IBM AppFlow GitHub application prerequisite

In order to configure the Enterprise Application Service instance to build the Java liberty application using the source code and the configuration repositories, the GitHub application **IBM AppFlow** must installed in the GitHub organization(s) hosting the repositories and enable to access both of them.

To install and configure the **IBM AppFlow** GitHub application refer to https://github.com/apps/ibm-enterprise-application-service

**Note:** in the case you need to configure an Enterprise Application Service instance in an environment different from IBM Cloud public platform, you need to install and configure a specific version of the **IBM AppFlow** GitHub application.

### Create an Enterprise Application Service instance without setting any repository

This module also supports to create an instance of the Enterprise Application Service without setting any source (GitHub or Maven) and configuration repository: in this case it will be possible to configure them through the Enterprise Application Service dashboard accessible through the dashboard URL returned in the `ease_instance` output details of this module.

### Java liberty sample application

For an example of source code and configuration repositories to Build, deploy and run in an Enterprise Application Service instance you can fork the repositories below:

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
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
| <a name="input_config_repo"></a> [config\_repo](#input\_config\_repo) | The URL for the repository storing the configuration to use for the application to run through Enterprise Application Service on IBM Cloud. | `string` | `null` | no |
| <a name="input_ease_name"></a> [ease\_name](#input\_ease\_name) | The name for the newly provisioned Enterprise Application Service instance. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"instance"` | no |
| <a name="input_maven_repository_password"></a> [maven\_repository\_password](#input\_maven\_repository\_password) | Maven repository authentication password if needed. Default to null. | `string` | `null` | no |
| <a name="input_maven_repository_username"></a> [maven\_repository\_username](#input\_maven\_repository\_username) | Maven repository authentication username if needed. Default to null. | `string` | `null` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | The desired pricing plan for Enterprise Application Service instance. | `string` | `"standard"` | no |
| <a name="input_region"></a> [region](#input\_region) | The desired region for deploying Enterprise Application Service instance. | `string` | `"us-east"` | no |
| <a name="input_repos_git_token"></a> [repos\_git\_token](#input\_repos\_git\_token) | The GitHub token to read from the application and configuration repositories. It cannot be null if var.source\_repo and var.config\_repo are not null. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The ID of the resource group to use for the creation of the Enterprise Application Service instance. | `string` | n/a | yes |
| <a name="input_source_repo"></a> [source\_repo](#input\_source\_repo) | The URL for the repository storing the source code of the application or the URL of the Maven artifact repository storing the existing prebuilt archive (WAR or EAR) to deploy and run through Enterprise Application Service on IBM Cloud. | `string` | `null` | no |
| <a name="input_source_repo_type"></a> [source\_repo\_type](#input\_source\_repo\_type) | Type of the source code repository. For maven source repository type, use value `maven`. Git for GitHub repository. Default value set to git. | `string` | `"git"` | no |
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
