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

resource "google_compute_instance" "master-database-server" {
  project      = "${var.project}"
  zone         = "${var.chef_node_zone}"
  name         = "master-database-server"
  machine_type = "${var.chef_node_machine_type}"
  tags         = ["master-psql-firewall", "tcp-lb-firewall"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190306"
    }
  }

  network_interface {
    network = "default"
    network_ip="10.138.0.16"
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

resource "google_compute_instance" "standby-database-server-1" {
  project      = "${var.project}"
  zone         = "${var.chef_node_zone_2}"
  name         = "slave-database-server-1"
  machine_type = "${var.chef_node_machine_type}"
  tags         = ["tcp-lb-firewall"]

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

resource "google_compute_instance" "standby-database-server-2" {
  project      = "${var.project}"
  zone         = "${var.chef_node_zone_3}"
  name         = "slave-database-server-2"
  machine_type = "${var.chef_node_machine_type}"
  tags         = ["tcp-lb-firewall"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20190306"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${var.chef_node_ip_address_3}"
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
