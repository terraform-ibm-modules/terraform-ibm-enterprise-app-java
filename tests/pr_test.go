// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
	"gopkg.in/yaml.v3"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const bdrCompleteExampleDir = "examples/bdr_complete"
const drCompleteExampleDir = "examples/dr_complete"
const region = "us-east"
const fullyConfigurableSolutionTerraformDir = "solutions/fully-configurable"

// test application source and config repositories
const appSourceRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started"
const appConfigRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started-config"

// test application source and config repositories
const mavenAppSourceRepo = "https://repo.maven.apache.org/maven2"
const mavenAppConfigRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started-config"
const mavenAppUsername = "username"
const mavenAppPassword = "password" // pragma: allowlist secret

// resource group to use as existing one for the DA test
const daExistingResourceGroup = "geretain-test-e4j"

// plan to use for tests
const testPlan = "free" // free plan is used for testing but its catalog name is "Trial"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// var permanentResources map[string]interface{}
var sharedInfoSvc *cloudinfo.CloudInfoService

type Config struct {
	SmCRN                  string `yaml:"secretsManagerCRN"`
	GhTokenSecretId        string `yaml:"geretain-public-gh-token-dev-user"`
	SubscriptionIdSecretId string `yaml:"geretain-appmod-ease4j-subscription-id"`
	MQCapacityInstanceCRN  string `yaml:"mq_capacity_crn"`
}

var smCRN string
var ghTokenSecretId string
var ghTokenSecretCRN string
var subscriptionIdSecretId string
var subscriptionIdSecretCRN string
var mqCapacityInstanceCRN string

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	// Read the YAML file contents
	data, err := os.ReadFile(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}
	// Create a struct to hold the YAML data
	var config Config
	// Unmarshal the YAML data into the struct
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		log.Fatal(err)
	}

	// Parse the SM CRN from data and setting combined test input values used in TestRunDefaultExample and TestRunUpgradeExamplen
	smCRN = config.SmCRN
	ghTokenSecretId = config.GhTokenSecretId               // pragma: allowlist secret
	subscriptionIdSecretId = config.SubscriptionIdSecretId // pragma: allowlist secret
	mqCapacityInstanceCRN = config.MQCapacityInstanceCRN

	// generating secret CRN from SM CRN and secret ID
	ghTokenSecretCRN = fmt.Sprintf("%ssecret:%s", strings.TrimSuffix(smCRN, ":"), ghTokenSecretId)               // pragma: allowlist secret
	subscriptionIdSecretCRN = fmt.Sprintf("%ssecret:%s", strings.TrimSuffix(smCRN, ":"), subscriptionIdSecretId) // pragma: allowlist secret
	mqCapacityInstanceCRN = config.MQCapacityInstanceCRN

	log.Printf("Using SM CRN %s to pull GitHub token", ghTokenSecretCRN) // pragma: allowlist secret
	log.Printf("Using SM CRN %s to pull SubscriptionID", subscriptionIdSecretCRN)
	log.Printf("Using MQ capacity instance CRN %s for S2S policy", mqCapacityInstanceCRN)

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string, terraformVars map[string]interface{}) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     dir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		Region:           region,
		TerraformVars:    terraformVars,
		CloudInfoService: sharedInfoSvc,
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	// disabling parallel tests while waiting for valid values for maven repository to avoid failure of test when reusing the same repos
	// t.Parallel()

	extTerraformVars := map[string]interface{}{
		"subscription_id_secret_crn": subscriptionIdSecretCRN,
		"plan":                       testPlan,
	}

	options := setupOptions(t, "ease-basic", basicExampleDir, extTerraformVars)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBdrCompleteExample(t *testing.T) {
	// disabling parallel tests while waiting for valid values for maven repository to avoid failure of test when reusing the same repos
	// t.Parallel()

	extTerraformVars := map[string]interface{}{
		"source_repo":                appSourceRepo,
		"config_repo":                appConfigRepo,
		"repos_git_token_secret_crn": ghTokenSecretCRN,
		"subscription_id_secret_crn": subscriptionIdSecretCRN,
		"plan":                       testPlan,
	}

	options := setupOptions(t, "bdr-complete", bdrCompleteExampleDir, extTerraformVars)

	options.SkipTestTearDown = true
	defer func() {
		options.TestTearDown()
	}()

	_, err := options.RunTestConsistency()
	if assert.Nil(t, err, "Consistency test should not have errored") {
		// retrieving dashboard URL to perform HTTP GET request to confirm the application is successfully started
		outputs := options.LastTestTerraformOutputs
		assert.Equal(t, checkDashboardUrl(t, outputs), true, "Checking dashboardURL failed")
	}
}

func TestRunDrCompleteExample(t *testing.T) {
	// disabling parallel tests while waiting for valid values for maven repository to avoid failure of test when reusing the same repos
	// t.Parallel()

	extTerraformVars := map[string]interface{}{
		"source_repo":                mavenAppSourceRepo,
		"config_repo":                mavenAppConfigRepo,
		"repos_git_token_secret_crn": ghTokenSecretCRN,
		"subscription_id_secret_crn": subscriptionIdSecretCRN,
		"plan":                       testPlan,
		"maven_repository_username":  mavenAppUsername,
		"maven_repository_password":  mavenAppPassword, // pragma: allowlist secret
	}

	options := setupOptions(t, "dr-complete", drCompleteExampleDir, extTerraformVars)

	options.SkipTestTearDown = true
	defer func() {
		options.TestTearDown()
	}()

	_, err := options.RunTestConsistency()
	if assert.Nil(t, err, "Consistency test should not have errored") {
		// retrieving dashboard URL to perform HTTP GET request to confirm the application is successfully started
		outputs := options.LastTestTerraformOutputs
		assert.Equal(t, checkDashboardUrl(t, outputs), true, "Checking dashboardURL failed")
	}
}

func TestRunUpgradeExample(t *testing.T) {
	// disabling parallel tests to avoid failure of test when reusing the same repos
	// t.Parallel()

	extTerraformVars := map[string]interface{}{
		"subscription_id_secret_crn": subscriptionIdSecretCRN,
		"plan":                       testPlan,
	}

	options := setupOptions(t, "ease-upgrade", basicExampleDir, extTerraformVars)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunStandardSolutionSchematics(t *testing.T) {
	// disabling parallel tests to avoid failure of test when reusing the same repos
	// t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/*/*.tf",
			fullyConfigurableSolutionTerraformDir + "/*.tf",
		},
		TemplateFolder:         fullyConfigurableSolutionTerraformDir,
		Tags:                   []string{"test-schematic"},
		Prefix:                 "ease-da",
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		Region:                 "us-east",
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "provider_visibility", Value: "public", DataType: "string"},
		{Name: "source_repo", Value: appSourceRepo, DataType: "string"},
		{Name: "config_repo", Value: appConfigRepo, DataType: "string"},
		{Name: "repos_git_token_secret_crn", Value: ghTokenSecretCRN, DataType: "string"},
		{Name: "subscription_id_secret_crn", Value: subscriptionIdSecretCRN, DataType: "string"},
		{Name: "subscription_id", Value: nil, DataType: "string"},
		{Name: "plan", Value: testPlan, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "instance_name", Value: fmt.Sprintf("instance-%s", common.UniqueId(3)), DataType: "string"},
		{Name: "existing_resource_group_name", Value: daExistingResourceGroup, DataType: "string"},
		{Name: "mq_s2s_policy_enable", Value: true, DataType: "bool"},
		{Name: "mq_s2s_policy_target_crn", Value: mqCapacityInstanceCRN, DataType: "string"},
		{Name: "db2_s2s_policy_enable", Value: false, DataType: "bool"},
		// DB2 S2S policy currently not tested - if to test we need to explore how to create the pre-existing instance during the test and destroy it at the end
		// {Name: "db2_s2s_policy_target_crn", Value: db2InstanceForEase4JCRN, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunStandardSolutionUpgradeSchematics(t *testing.T) {
	// disabling parallel tests to avoid failure of test when reusing the same repos
	// t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/*/*.tf",
			fullyConfigurableSolutionTerraformDir + "/*.tf",
		},
		TemplateFolder:         fullyConfigurableSolutionTerraformDir,
		Tags:                   []string{"test-schematic"},
		Prefix:                 "ej-uda",
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		Region:                 "us-east",
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "provider_visibility", Value: "public", DataType: "string"},
		{Name: "source_repo", Value: appSourceRepo, DataType: "string"},
		{Name: "config_repo", Value: appConfigRepo, DataType: "string"},
		{Name: "repos_git_token_secret_crn", Value: ghTokenSecretCRN, DataType: "string"},
		{Name: "subscription_id_secret_crn", Value: subscriptionIdSecretCRN, DataType: "string"},
		{Name: "subscription_id", Value: "null", DataType: "string"},
		{Name: "plan", Value: testPlan, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "instance_name", Value: fmt.Sprintf("instance-%s", common.UniqueId(3)), DataType: "string"},
		{Name: "existing_resource_group_name", Value: daExistingResourceGroup, DataType: "string"},
		{Name: "mq_s2s_policy_enable", Value: true, DataType: "bool"},
		{Name: "mq_s2s_policy_target_crn", Value: mqCapacityInstanceCRN, DataType: "string"},
		{Name: "db2_s2s_policy_enable", Value: false, DataType: "bool"},
		// DB2 S2S policy currently not tested - if to test we need to explore how to create the pre-existing instance during the test and destroy it at the end
		// {Name: "db2_s2s_policy_target_crn", Value: db2InstanceForEase4JCRN, DataType: "string"},
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.NoError(t, err, "Schematic Upgrade Test had an unexpected error")
	}
}

// checking the dashboard URL in the terraform output
// the response is expected to have (1) statusCode 200 (2) status 200 OK (3) length of the response greater than 0
// returning true if the dashboard URL is found on the terraform output, if not empty, and if the checks on the response are successful, false otherwise
func checkDashboardUrl(t *testing.T, terraformOutput map[string]interface{}) bool {
	_, tfOutputsErr := testhelper.ValidateTerraformOutputs(terraformOutput, "ease_instance_dashboard_url")
	if assert.Nil(t, tfOutputsErr, tfOutputsErr) {
		dashboardUrl := terraformOutput["ease_instance_dashboard_url"].(string)
		t.Logf("EASe instance dashboard Url going to be used is %s", dashboardUrl)
		if assert.NotEmpty(t, dashboardUrl, "EASe application dashboardUrl retrieved from terraform output but it looks empty") {
			resp, err := http.Get(dashboardUrl)
			if assert.Nil(t, err, "Error in performing request towards dashboardURL") {
				defer func() {
					err := resp.Body.Close()
					if assert.Nil(t, err, "Error in closing response body") {
						t.Logf("Error in closing response body")
					}
				}()
				// collecting response details
				statusCode := resp.StatusCode
				status := resp.Status
				respSize := resp.ContentLength
				// reading body (body not used as not needed)
				_, err := io.ReadAll(resp.Body)
				if assert.Nil(t, err, "Error in reading response body") {
					t.Logf("Got response from %s - statusCode %d - status %s - response size %d", dashboardUrl, statusCode, status, uint64(respSize))
					if assert.Equal(t, 200, statusCode, "Response status code different from expected 200") && assert.Equal(t, "200 OK", status, "Response status different from expected '200 OK'") && assert.Greater(t, uint64(respSize), uint64(0), "Response size not greater than 0") {
						t.Logf("All checks on response got from dashboard URL %s are successful", dashboardUrl)
						return true
					}
				}
			}
		}
	}
	return false
}

func TestAddonsDefaultConfiguration(t *testing.T) {

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "ease",
		ResourceGroup: resourceGroup,
		QuietMode:     false, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-ease",
		"fully-configurable",
		map[string]interface{}{
			"prefix":                       options.Prefix,
			"existing_resource_group_name": resourceGroup,
			"subscription_id":              subscriptionIdSecretId,
			"secrets_manager_service_plan": "trial",
			"plan":                         "free",
			"secrets_manager_region":       "eu-de",
		},
	)

	err := options.RunAddonTest()
	require.NoError(t, err)
}

// TestDependencyPermutations runs dependency permutations for all dependencies
func TestDependencyPermutations(t *testing.T) {

	t.Skip("Skip permutation test until some fix is done in testwrapper to tackle heavy load")
	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing: t,
		Prefix:  "ease-perm",
		AddonConfig: cloudinfo.AddonConfig{
			OfferingName:   "deploy-arch-ibm-ease",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"prefix":                       "ease-perm",
				"existing_resource_group_name": resourceGroup,
				"subscription_id":              subscriptionIdSecretId,
				"secrets_manager_service_plan": "trial",
				"secrets_manager_region":       "eu-de",
			},
		},
	})

	err := options.RunAddonPermutationTest()
	assert.NoError(t, err, "Dependency permutation test should not fail")
}
