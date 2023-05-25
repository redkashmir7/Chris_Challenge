#!/bin/bash

response=$(curl -s http://www.chriscomcastcode.com)
if [[ "$response" == *"Hello World!"* ]]; then
  echo "Website is working as expected"
else
  echo "Website is not working as expected"
  exit 1
fi
