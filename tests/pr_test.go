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
const basicExampleDir = "examples/basic"
const completeExampleDir = "examples/complete"
const region = "us-east"

// test application source and config repositories
const appSourceRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started"
const appConfigRepo = "https://github.com/tim-openliberty-appflow-test/sample-getting-started-config"

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

	// not setting github token as the sample repositories are public
	extTerraformVars := map[string]interface{}{
		"source_repo": appSourceRepo,
		"config_repo": appConfigRepo,
	}

	options := setupOptions(t, "ease-complete", completeExampleDir, extTerraformVars)

	options.SkipTestTearDown = true
	defer func() {
		options.TestTearDown()
	}()

	// // retrieving dashboard URL to perform curl to confirm the application is successfully deployed
	// _, err := options.RunTestConsistency()
	// if assert.Nil(t, err, "Consistency test should not have errored") {
	// 	outputs := options.LastTestTerraformOutputs
	// 	_, tfOutputsErr := testhelper.ValidateTerraformOutputs(outputs, "cluster_id")
	// 	if assert.Nil(t, tfOutputsErr, tfOutputsErr) {

	// 		// get cluster config
	// 		cloudinfosvc, err := cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	// 		if assert.Nil(t, err, "Error creating cloud info service") {
	// 			clusterConfigPath, err := cloudinfosvc.GetClusterConfigConfigPath(outputs["cluster_id"].(string))
	// 		}
	// 	}
	// }

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
