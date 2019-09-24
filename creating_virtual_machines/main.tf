resource "google_compute_instance" "utility" {
  name         = "utility"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
  }
}

resource "google_compute_instance" "windows" {
  name         = "windows"
  machine_type = "n1-standard-2"
  zone         = "europe-west2-a"

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2016-core"
      size  = 100
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
  }
}

resource "google_compute_instance" "custom" {
  name         = "custom"
  machine_type = "custom-6-32768"
  zone         = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "default"
    subnetwork = "default"
  }
}
