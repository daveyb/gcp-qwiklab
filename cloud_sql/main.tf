resource "google_compute_instance" "mydb-client" {
  name         = "mydb-client"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
    access_config {
      // Ephemeral IP
    }
  }
}

data "null_data_source" "auth_netw_mysql_allowed_1" {
  inputs = {
    name  = "mydb-client"
    value = "${google_compute_instance.mydb-client.network_interface.0.access_config.0.nat_ip}/32"
  }
}

resource "google_sql_database_instance" "infra-db" {
  name = "infra-db"
  database_version = "MYSQL_5_7"
  region = "us-central1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-n1-standard-1"
    disk_type = "PD_SSD"
    disk_size = "10"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks = [
        "${data.null_data_source.auth_netw_mysql_allowed_1.*.outputs}"
      ]
    }
  }
}

output "mydb_external_ip" {
  value = "${google_compute_instance.mydb-client.network_interface.0.access_config.0.nat_ip}"
}
