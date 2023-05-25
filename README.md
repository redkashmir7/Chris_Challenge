# Terraform Web Server Deployment

This repository contains the Terraform configuration files for deploying a secure and scalable static web application in AWS in fulfilllment of Comcast's coding challange.

The deployment consists of an EC2 instance deployed by an Auto Scaling Group (ASG), configured with a running Apache server to host the web application, an Application Load Balancer (ALB) for managing network traffic, an Auto Scaling Group (ASG) to handle scalability, Route 53 for DNS management, and Amazon Certificate Manager (ACM) for securing HTTP traffic.

## Repository Structure

- `main.tf` - Contains the provider configuration and calls to the modules
- `_data.tf` - Contains all data blocks
- `_data.tf` - Contains all variable blocks used in code
- `_outputs.tf` - Contains needed output blocks
- `vpc.tf` - Contains the configuration for the VPC and related networking resources
- `alb.tf` - Contains the configuration for the Application Load Balancer
- `asg.tf` - Contains the configuration for the Auto Scaling Group
- `acm.tf` - Contains the configuration for Amazon Certificate Manager
- `test.sh` - A Bash script for testing the website

## Prerequisites
- AWS account with necessary permissions
- Terraform installed (version 0.14 or later)
- AWS CLI installed and configured
- `jq` and `curl` tools installed for running the test script

## Deployment Instructions
1. Move into web_server directory:
    - cd web_server
2. Initialize Terraform:
    - terraform init
3. Validate the configuration:
    - terrafrom validate
4. Preview the changes to be made:
    - terraform plan
5. Apply the configuration:
    - terraform apply


## Testing

After applying the Terraform configuration, you can verify if the website is accessible by running the `test.sh` script. This script sends a GET request to the website and checks if the response contains the expected content. It can be ran with the following:

```bash
./test.sh
```

# Credit Card Validator

This Python function validates a credit card number using regular expressions. It checks the starting digits, length, group separation, and for consecutive repeated digits. It contains sucess and failure cases for the different required rules at the following address: https://www.hackerrank.com/challenges/validating-credit-card-number/problem