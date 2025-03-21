# Enterprise Application Service for Java

This architecture creates an instance of Enterprise Application Service for Java (also known as EASe4J) and supports provisioning of the following resources:

- A resource group, if an existing one is not passed in.
- An Enterprise Application Service for Java instance.
- An optional [Service to Service authorisation policy](https://cloud.ibm.com/docs/account?topic=account-serviceauth) to authorise the Enterprise Application instance to reach an instance of MQ service. The authorisation policy is configured at MQ resource instance scope if enabled.
- An optional [Service to Service authorisation policy](https://cloud.ibm.com/docs/account?topic=account-serviceauth) to authorise the Enterprise Application instance to reach an instance of DB2 service. The authorisation policy is configured at DB2 resource instance scope if enabled.

<!-- ![Enterprise Application Service for Java architecture](../../reference-architecture/deployable-architecture-ease.svg) -->

### Enterprise Application Service for Java instance source and configuration options

The EASe4J service allows to build, deploy and run an application by setting the GitHub repositories to clone for the application sources and environment configurations (Build Deploy and Run use case), or to deploy and run an application by setting the Maven repository for the application built artifact and the GitHub repository to clone for the application environment configuration (Deploy and Run use case).
For more details about the two use-cases support please refer to the [module README doc](../../README.md#enterprise-application-service-use-cases-support)

### Mandatory input parameters for both the use cases

1. The IBM Cloud API Key (https://cloud.ibm.com/iam/apikeys) for the account where to deploy the Enterprise Application Service instance
1. Resource Group ID (https://cloud.ibm.com/account/resource-groups) containing the Enterprise Application Service instance

### Token and Subscription ID secrets input variables

- The input variables `repos_git_token` and `repos_git_token_secret_crn` are mutually exclusive: if both are provided with a value the second one is used.

- The input variables `subscription_id` and `subscription_id_secret_crn` are mutually exclusive: if both are provided with a value the second one is used.

#### IBM AppFlow GitHub application prerequisite

In order to configure the Enterprise Application Service instance to build the Java liberty application using the source code and the configuration repositories, the GitHub application **IBM AppFlow** must installed in the GitHub organization(s) hosting the repositories and enable to access both of them.

To install and configure the **IBM AppFlow** GitHub application refer to https://github.com/apps/ibm-enterprise-application-service

**Note:** in the case you need to configure an Enterprise Application Service instance in an environment different from IBM Cloud public platform, you need to install and configure a specific version of the **IBM AppFlow** GitHub application.

### Build Deploy and Run use case input parameters

The following optional input parameters are required in order to pre-configure the Enterprise Application Service instance for the BDR use case:

1. URL of the GitHub repository storing the Java liberty application source code to build in the Enterprise Application Service instance
1. URL of the GitHub repository storing the Java liberty application configuration to build in the Enterprise Application Service instance
1. GitHub token with read access to the source code and to the configuration repositories.

**Note:** all these parameters are mandatory in the case any of them is different than their default null value, with the GitHub token mandatory also if the source code and the configuration repositories are both public. When all of them are left to the default null value it will be possible to configure the instance with their values once the instance is successfully created, as describe [here](#create-an-enterprise-application-service-instance-without-setting-any-repository)

## Deploy and Run use case input parameters

The following optional input parameters are required in order to pre-configure the Enterprise Application Service instance for the DR use case:

1. URL of the Maven repository storing the built Java liberty application to run in the Enterprise Application Service instance
2. URL of the GitHub repository storing the Java liberty application configuration to run in the Enterprise Application Service instance
3. GitHub token with read access to the configuration repositories.

**Note:** like the BDR use case, all these parameters are mandatory in the case any of them is different than their default null value. When all of them are left to the default null value it will be possible to configure the instance with their values once the instance is successfully created, as describe [here](#create-an-enterprise-application-service-instance-without-setting-any-repository)


### Create an Enterprise Application Service instance without setting any repository

This Deployable Architecture allows also to create an instance of the Enterprise Application Service without setting any source and configuration repository: in the case the source code (GitHub or Maven) and the configuration repositories are not set at Enterprise Application Service instance deployment time, it will be possible to configure them through the Enterprise Application Service dashboard url that will be included in the `ease_instance` output details of this module.

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
