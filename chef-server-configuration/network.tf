resource "google_compute_instance_group" "us-east1-database" {
  name = "us-east1-databases-instance-group"
  zone = "us-east1-b"
  instances = [ "${google_compute_instance.standby-database-server-1.self_link}" ]
  named_port {
    name = "database-port"
    port = "5432"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group" "europe-west1-database" {
  name = "europe-west1-databases-instance-group"
  zone = "europe-west1-b"
  instances = [ "${google_compute_instance.standby-database-server-2.self_link}" ]
  named_port {
    name = "database-port"
    port = "5432"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "default" {
  name          = "database-load-balancer"
  protocol      = "TCP"
  port_name     = "database-port"
  timeout_sec   = 10
  backend { 
      group = "${google_compute_instance_group.us-east1-database.self_link}"
  }
  backend {
      group = "${google_compute_instance_group.europe-west1-database.self_link}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}

resource "google_compute_health_check" "default" {
  name               = "health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "5432"
  }
}

resource "google_compute_target_tcp_proxy" "default" {
  name            = "database-proxy"
  backend_service = "${google_compute_backend_service.default.self_link}"
}


resource "google_compute_global_forwarding_rule" "default" {
  target     = "${google_compute_target_tcp_proxy.default.self_link}"
  name       = "database-forwarding-rule"
  port_range = "110"
}


