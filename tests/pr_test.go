// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic-no-config"
const completeExampleDir = "examples/complete"
const region = "us-east"

// test application source and config repositories
const appSourceRepo = "https://github.com/vb-test-appflow-org/wasease-sample-getting-started_v0.1"
const appConfigRepo = "https://github.com/vb-test-appflow-org/wasease_sample-getting-started-config_v0.1"

func setupOptions(t *testing.T, prefix string, dir string, terraformVars map[string]interface{}) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		Region:        region,
		TerraformVars: terraformVars,
	})
	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()
	t.Skip("Skipping test until available in production IBM Cloud.")

	options := setupOptions(t, "ease", basicExampleDir, nil)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()
	t.Skip("Skipping test until available in production IBM Cloud.")

	extTerraformVars := map[string]interface{}{
		"source_repo": appSourceRepo,
		"config_repo": appConfigRepo,
	}

	options := setupOptions(t, "ease", completeExampleDir, extTerraformVars)

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
