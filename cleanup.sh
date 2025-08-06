#!/bin/bash

# Cleanup script for Terraform state and local files
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -rf .terraform
