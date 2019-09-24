# GCP Qwiklabs Terraform
_NOTE_ this is very much a WIP, done as I was going through the labs. Hardcoded values, bad practices, poor formatting... it's all here. Use at your own risk!

## Getting Started
1. `brew cask install google-cloud-sdk`
1. Log into GCP portal, navigate to IAM, and create a new key for the `ql-api` service account (you won't have access to grant service account permissions using the qwiklabs-provided login)
1. Download the service account json file, saving it to `~/.config/gcloud/***.json`
1. `export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/***.json`
1. Add your project name to your ENV `export GOOGLE_PROJECT=<project>`
1. Change directory into the directory for the module you're working on
1. Symlink the provider.tf `ln -s ../provider.tf provider.tf`
1. ```terraform init && terraform plan```
