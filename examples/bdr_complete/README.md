# Build, deploy and run complete example

A Build, deploy and run use-case example to show how to provision an Enterprise Application Service instance by passing application source and configuration repositories as input.
In addiction to the two repositories, the example shows how to include the GitHub token with the right permissions to access the repositories: in the example the token is pulled from an IBM Cloud secrets manager instance where it is stored, by passing the secret CRN which is used to extract the Secrets Manager instance, its region and the secretID to pull the secret value
Note that the three parameters (repositories and token) are mandatory if any of them is not null.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A new Enterprise Application Service instance in the given resource group on an IBM Cloud account.
