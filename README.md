## Getting Started
1. `brew cask install google-cloud-sdk`
1. Log into GCP portal, navigate to IAM, and create a new key for the `ql-api` service account (you won't have access to grant service account permissions using the qwiklabs-provided login)
1. Download the service account json file, saving it to `~/.config/gcloud/ql-api.json`
1. Add your project name to `provider.tf`
1. ```terraform init && terraform plan```
