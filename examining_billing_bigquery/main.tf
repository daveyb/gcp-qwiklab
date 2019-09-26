resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "imported_billing_data"
  friendly_name               = "billing"
  description                 = "Imported billing data"
  location                    = "US"
  default_table_expiration_ms = 86400000

  access {
    role          = "OWNER"
    special_group = "allAuthenticatedUsers"
  }
}

# attaches data instead of importing
resource "google_bigquery_table" "sampleinfo" {
  dataset_id = "${google_bigquery_dataset.dataset.dataset_id}"
  table_id   = "sampleinfotable"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    csv_options {
      quote             = ""
      skip_leading_rows = 1
    }

    source_uris = [
      "gs://cloud-training/archinfra/export-billing-example.csv",
    ]
  }
}
