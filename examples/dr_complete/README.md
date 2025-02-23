# Deploy and run complete example

A Deploy and run use-case example to show how to provision an Enterprise Application Service instance by passing an already built maven application through its maven repository URL as source repository and the application configuration through the config repository as input parameters.
The example sets also the var.source_repo_type input variable to "maven" and the "username" and "password" values to a set of fake values for testing purposes
In addiction to the configuration repository, the example shows how to
- include the GitHub token with the right permissions to access it: in the example the token is pulled from an IBM Cloud secrets manager instance where it is stored, by passing the secret CRN which is used to extract the Secrets Manager instance, its region and the secretID to pull the secret value.
- include the maven repository credentials (username and password)
Note that the three parameters, maven and configuration repositories and the github token, are mandatory if any of them is not null.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A new Enterprise Application Service instance in the given resource group on an IBM Cloud account.
