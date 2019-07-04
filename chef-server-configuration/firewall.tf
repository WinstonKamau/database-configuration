resource "google_compute_firewall" "master-firewall" {
  name    = "default-allow-master-psql"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
# should be changed later to restrict only apps allowed to modify it
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["master-psql-firewall"]
}


resource "google_compute_firewall" "psql-firewall" {
  name    = "default-allow-psql"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["tcp-lb-firewall"]
}

resource "google_compute_firewall" "http-firewall" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-firewall"]
}

resource "google_compute_firewall" "https-firewall" {
  name    = "default-allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-firewall"]
}