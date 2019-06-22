data "google_compute_zones" "available" {}

resource "google_compute_instance" "chef-server-instance" {
  project      = "${var.project}"
  zone         = "${var.chef_server_zone}"
  name         = "${var.chef_server_name}"
  machine_type = "${var.machine_type}"
  tags         = ["http-firewall", "https-firewall"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190306"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${var.chef_ip_address}"
    }	
  }
  metadata_startup_script = "${file("install_chef_server.sh")}"

    metadata {
    hostName    = "${var.hostname}"
  }
}

resource "google_compute_instance" "primary-database-server" {
  project      = "${var.project}"
  zone         = "${var.chef_node_zone}"
  name         = "${var.chef_node_name}"
  machine_type = "${var.chef_node_machine_type}"
  tags         = ["http-firewall", "https-firewall"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190306"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${var.chef_node_ip_address}"
    }	
  }
  metadata_startup_script = "${file("install_chef_node.sh")}"

    metadata {
    chefNodePublicKey    = "${file("chef_node_ssh_key.pub")}"
  }

  service_account {
    scopes = ["storage-full"]
  }
  
}

resource "google_compute_instance" "standby-database-server" {
  project      = "${var.project}"
  zone         = "${var.chef_node_zone_2}"
  name         = "${var.chef_node_name_2}"
  machine_type = "${var.chef_node_machine_type}"
  tags         = ["http-firewall", "https-firewall"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190306"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${var.chef_node_ip_address_2}"
    }	
  }
  metadata_startup_script = "${file("install_chef_node.sh")}"

    metadata {
    chefNodePublicKey    = "${file("chef_node_ssh_key.pub")}"
  }

  service_account {
    scopes = ["storage-full"]
  }
 
}
