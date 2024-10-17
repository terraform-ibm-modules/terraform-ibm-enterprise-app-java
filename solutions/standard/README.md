# Enterprise Application Service for Java

This architecture creates an instance of Enterprise Application Service for Java and supports provisioning of the following resources:

- A resource group, if one is not passed in.
- An Enterprise Application Service for Java.
- An optional [Service to Service authorisation policy](https://cloud.ibm.com/docs/account?topic=account-serviceauth) to authorise the Enterprise Application instance to reach an instance of MQ service. The same authorisation policy can be configured at account scope, at resource scope or at resource group scope according to the source and target attributes

<!-- ![Enterprise Application Service for Java architecture](../../reference-architecture/deployable-architecture-ease.svg) -->

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
