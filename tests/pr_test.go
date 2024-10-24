// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"io"
	"net/http"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"
const completeExampleDir = "examples/complete"
const region = "us-east"
const standardSolutionTerraformDir = "solutions/standard"

// test application source and config repositories
// TO DO
// to re-enable when service is in production and the secretID can be loaded for the token
// const appSourceRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started"
// const appConfigRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started-config"

// Define a struct with fields that match the structure of the YAML data
// TO DO
// to re-enable when service is in production and the secretID can be loaded for the token
// const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// var permanentResources map[string]interface{}
var sharedInfoSvc *cloudinfo.CloudInfoService

// TO DO
// to re-enable when service is in production and the secretID can be loaded for the token
// type Config struct {
// 	SmGuid          string `yaml:"secretsManagerGuid"`
// 	SmRegion        string `yaml:"secretsManagerRegion"`
// 	GhTokenSecretId string `yaml:"geretain-public-gh-token-dev-user"`
// }

// TO DO
// to re-enable when service is in production and the secretID can be loaded for the token

// var smGuid string
// var smRegion string
// var rgId string
// var ghTokenSecretId string

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	// var err error
	// permanentResources, err = common.LoadMapFromYaml(yamlLocation)

	// Read the YAML file contents
	// TO DO
	// to re-enable when service is in production and the secretID can be loaded for the token
	// data, err := os.ReadFile(yamlLocation)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// Create a struct to hold the YAML data
	// TO DO
	// to re-enable when service is in production and the secretID can be loaded for the token
	// var config Config
	// Unmarshal the YAML data into the struct
	// err = yaml.Unmarshal(data, &config)
	// if err != nil {
	// 	log.Fatal(err)
	// }

	// Parse the SM guid and region from data and setting all-combined test input values used in TestRunDefaultExample and TestRunUpgradeExample
	// TO DO
	// to re-enable when service is in production and the secretID can be loaded for the token
	// smGuid = config.SmGuid
	// smRegion = config.SmRegion
	// ghTokenSecretId = config.GhTokenSecretId

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
	t.Parallel()
	// TODO remove skip test
	t.Skip("Skipping test until available in production IBM Cloud.")

	options := setupOptions(t, "ease-basic", basicExampleDir, nil)

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

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()
	// TODO remove skip test
	t.Skip("Skipping test until available in production IBM Cloud.")

	// not setting github token as the sample repositories are public
	extTerraformVars := map[string]interface{}{
		// TO DO
		// to re-enable when service is in production and the secretID can be loaded for the token
		// "source_repo": appSourceRepo,
		// "config_repo": appConfigRepo,
		// "repos_git_token_existing_secrets_manager_id":     smGuid,
		// "repos_git_token_existing_secrets_manager_region": smRegion,
		// "repos_git_token_secret_id":                       ghTokenSecretId,
	}

	options := setupOptions(t, "ease-complete", completeExampleDir, extTerraformVars)

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
	t.Parallel()
	// TODO remove skip test
	t.Skip("Skipping test until available in production IBM Cloud.")

	options := setupOptions(t, "ease-upgrade", basicExampleDir, nil)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunStandardSolutionSchematics(t *testing.T) {
	t.Parallel()
	// TODO remove skip test
	t.Skip("Skipping test until available in production IBM Cloud.")

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/*/*.tf",
			standardSolutionTerraformDir + "/*.tf",
		},
		TemplateFolder:         standardSolutionTerraformDir,
		Tags:                   []string{"test-schematic"},
		Prefix:                 "ease-da",
		ResourceGroup:          resourceGroup,
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		Region:                 "us-east",
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		// TO DO
		// to re-enable when service is in production and the secretID can be loaded for the token
		// {Name: "source_repo", Value: appSourceRepo, DataType: "string"},
		// {Name: "config_repo", Value: appConfigRepo, DataType: "string"},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

// checking the dashboard URL in the terraform output
// the response is expected to have (1) statusCode 200 (2) status 200 OK (3) lenght of the response greater than 0
// returning true if the dashboard URL is found on the terraform output, if not empty, and if the checks on the response are successful, false otherwise
func checkDashboardUrl(t *testing.T, terraformOutput map[string]interface{}) bool {
	_, tfOutputsErr := testhelper.ValidateTerraformOutputs(terraformOutput, "ease_instance_dashboard_url")
	if assert.Nil(t, tfOutputsErr, tfOutputsErr) {
		dashboardUrl := terraformOutput["ease_instance_dashboard_url"].(string)
		t.Logf("EASe instance dashboard Url going to be used is %s", dashboardUrl)
		if assert.NotEmpty(t, dashboardUrl, "EASe application dashboardUrl retrieved from terraform output but it looks empty") {
			resp, err := http.Get(dashboardUrl)
			if assert.Nil(t, err, "Error in performing request towards dashboardURL") {
				defer resp.Body.Close()
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
