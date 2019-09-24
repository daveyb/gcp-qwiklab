provider "google" {
  credentials = "${file("~/.config/gcloud/ql-api.json")}"
  project = ""
}
