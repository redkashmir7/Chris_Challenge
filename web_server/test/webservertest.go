package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/http-helper"
    "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestWebServer(t *testing.T) {
    t.Parallel()

    terraformOptions := &terraform.Options{
        // The path to where your Terraform code is located
        TerraformDir: "../terraform",
    }

    // At the end of the test, run `terraform destroy` to clean up any resources that were created
    defer terraform.Destroy(t, terraformOptions)

    // This will run `terraform init` and `terraform apply` and fail the test if there are any errors
    terraform.InitAndApply(t, terraformOptions)

    // Validate the server is working correctly
    validateServerIsWorking(t, terraformOptions)
}

func validateServerIsWorking(t *testing.T, terraformOptions *terraform.Options) {
    // Run `terraform output` to get the value of an output variable
    url := terraform.Output(t, terraformOptions, "url")

    // Validate the server returns a 200 response with the right body
    http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 10, 10)
}
