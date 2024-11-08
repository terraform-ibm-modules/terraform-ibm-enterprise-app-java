# Enterprise Application Service for Java

This architecture creates an instance of Enterprise Application Service for Java (also known as EASe4J) and supports provisioning of the following resources:

- A resource group, if an existing one is not passed in.
- An Enterprise Application Service for Java instance.
- An optional [Service to Service authorisation policy](https://cloud.ibm.com/docs/account?topic=account-serviceauth) to authorise the Enterprise Application instance to reach an instance of MQ service. The same authorisation policy can be configured at account scope, at resource scope or at resource group scope according to the source and target attributes.

### Enterprise Application Service for Java instance source and configuration options

The EASe4J service allows to build and run an application by setting the GitHub repositories to clone for the application sources and environment configurations. In order to configure this option through this architecture, the following input parameters can be configured:

- source_repo: the application source code repository
- config_repo: the application environment configuration repository
- repos_git_token: the GitHub token to access the above repositories (mandatory also if the repositories are public)
- repos_git_token_secret_crn: the CRN of the secret storing the value of the same GitHub token above on IBM Cloud Secrets Manager instance (the Secrets Manager instance, its region and the secret ID needed to pull the token value are extracted from the CRN)

The input variables `repos_git_token` and `repos_git_token_secret_crn` are mutually exclusive: if both are provided with a value the second one is used.

<!-- ![Enterprise Application Service for Java architecture](../../reference-architecture/deployable-architecture-ease.svg) -->

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
