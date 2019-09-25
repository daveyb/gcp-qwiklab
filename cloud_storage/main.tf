variable "bucket_1_name" {
  type = "string"
  default = "bucket-1"
}

resource "random_uuid" "storage" { 
  keepers {
    bucket_name = "${var.bucket_1_name}"
  }
}

resource "google_storage_bucket" "bucket_1" {
  name     = "${var.bucket_1_name}-${random_uuid.storage.result}"
  location = "us"
}

resource "google_storage_bucket_acl" "bucket_1_acl" {
  bucket = "${google_storage_bucket.bucket_1.name}"
  predefined_acl = "projectPrivate"
}
