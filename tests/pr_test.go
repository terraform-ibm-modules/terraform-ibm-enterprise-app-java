// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic-no-config"
const completeExampleDir = "examples/complete"
const region = "us-east"

// test application source and config repositories
// TODO change the following const with paramenters from permanentResources when moving to production
const appSourceRepo = "https://github.com/vb-test-appflow-org/wasease-sample-getting-started_v0.1"
const appConfigRepo = "https://github.com/vb-test-appflow-org/wasease_sample-getting-started-config_v0.1"

// TODO to make it loaded from env / SM when using a valid token
const gitTokenRepo = "XXX"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

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
	t.Skip("Skipping test until available in production IBM Cloud.")

	options := setupOptions(t, "ease-basic", basicExampleDir, nil)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()
	t.Skip("Skipping test until available in production IBM Cloud.")

	extTerraformVars := map[string]interface{}{
		"source_repo":     appSourceRepo,
		"config_repo":     appConfigRepo,
		"repos_git_token": gitTokenRepo,
	}

	options := setupOptions(t, "ease-complete", completeExampleDir, extTerraformVars)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()
	t.Skip("Skipping test until available in production IBM Cloud.")

	options := setupOptions(t, "ease-upgrade", basicExampleDir, nil)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
