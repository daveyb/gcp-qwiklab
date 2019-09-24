resource "google_compute_network" "auto_mode" {
  name        = "learnauto"
  description = "Learn about auto-mode networks"

  auto_create_subnetworks = true
}

resource "google_compute_network" "custom_mode" {
  name        = "learncustom"
  description = "Learn about custom networks"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "1" {
  name          = "subnet-1a"
  region        = "us-central1"
  ip_cidr_range = "192.168.5.0/24"
  network       = "${google_compute_network.custom_mode.self_link}"

  secondary_ip_range {
    range_name    = "subnet-1b"
    ip_cidr_range = "192.168.3.0/24"
  }
}

data "google_compute_subnetwork" "1" {
  name   = "${google_compute_subnetwork.1.name}"
  region = "us-central1"
}

resource "google_compute_subnetwork" "2" {
  name          = "subnet-2"
  region        = "us-west1"
  ip_cidr_range = "192.168.7.0/24"
  network       = "${google_compute_network.custom_mode.self_link}"
}

resource "google_compute_firewall" "default" {
  name    = "allow-ssh-icmp-rdp-learncustom"
  network = "${google_compute_network.custom_mode.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  target_tags = ["allow-defaults"]
}

resource "google_compute_instance" "learn-1" {
  count        = 2
  name         = "learn-${count.index + 1}"
  machine_type = "f1-micro"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "${google_compute_network.auto_mode.name}"
    subnetwork = "${google_compute_network.auto_mode.self_link}"
  }
}

resource "google_compute_instance" "learn-3" {
  name         = "learn-3"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "${google_compute_network.custom_mode.name}"
    subnetwork = "${google_compute_subnetwork.1.name}"
  }
}

resource "google_compute_instance" "learn-4" {
  name         = "learn-4"
  machine_type = "f1-micro"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "${google_compute_network.custom_mode.name}"
    subnetwork = "${data.google_compute_subnetwork.1.secondary_ip_range.range_name}"
  }
}

resource "google_compute_instance" "learn-5" {
  name         = "learn-5"
  machine_type = "f1-micro"
  zone         = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network    = "${google_compute_network.custom_mode.name}"
    subnetwork = "${google_compute_subnetwork.2.name}"
  }
}
