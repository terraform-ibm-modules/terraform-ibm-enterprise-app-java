# Build, deploy and run complete example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=enterprise-app-java-bdr_complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-enterprise-app-java/tree/main/examples/bdr_complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


A Build, deploy and run use-case example to show how to provision an Enterprise Application Service instance by passing application source and configuration repositories as input.
In addiction to the two repositories, the example shows how to include the GitHub token with the right permissions to access the repositories: in the example the token is pulled from an IBM Cloud secrets manager instance where it is stored, by passing the secret CRN which is used to extract the Secrets Manager instance, its region and the secretID to pull the secret value
Note that the three parameters (repositories and token) are mandatory if any of them is not null.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A new Enterprise Application Service instance in the given resource group on an IBM Cloud account.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
