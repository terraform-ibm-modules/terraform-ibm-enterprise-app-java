# IBM Enterprise Application Service for Java

This architecture creates an instance of IBM Enterprise Application Service for Java and supports provisioning of the following resources:

- A resource group, if one is not passed in.
- An IBM Enterprise Application Service for Java.

<!-- ![IBM Enterprise Application Service for Java architecture](../../reference-architecture/deployable-architecture-ease.svg) -->

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
