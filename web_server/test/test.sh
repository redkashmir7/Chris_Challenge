#!/bin/bash

# Move to parent directory and get needed info with validation
cd ..
elb_dns_name=$(terraform output -raw elb_dns_name)
if [ -z "$elb_dns_name" ]; then
  echo "Failed to retrieve the value of 'elb_dns_name' from Terraform output"
  exit 1
fi


# Use curl to fetch the webpage hosted on the ALB as well as trouble shot
response=$(curl -s -k "https://$elb_dns_name:443")
if [[ "$response" == *"301 Moved Permanently"* ]]; then
  new_location=$(echo "$response" | grep -i "Location:" | awk -F ': ' '{print $2}' | tr -d '\r')

  # Print the new location
  echo "The webpage has been permanently moved to: $new_location"

  # Fetch the content from the new location
  response=$(curl -s "$new_location")
fi

# Test
if [[ "$response" == *"Hello World!"* ]]; then
  echo "Website is working as expected"
else
  echo "Website is not working as expected"
  exit 1
fi