#!/bin/bash -e

# Cleans up various files to prepare for a fresh deployment and prevent conflicts w/ the state file.
rm -fr .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
