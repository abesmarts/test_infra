terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "vm_network" {
  name   = "vm-test-network"
  driver = "bridge"
  ipam_config {
    subnet  = var.network_cidr
    gateway = var.gateway_ip
  }
}

resource "docker_container" "web_vm" {
  name  = "web-vm-1"
  image = "ubuntu:22.04"
  command = ["/bin/bash", "-c", "tail -f /dev/null"]
  networks_advanced {
    name         = docker_network.vm_network.name
    ipv4_address = "198.51.100.10"
  }
  ports {
    internal = 80
    external = 8080
    protocol = "tcp"
  }
  ports {
    internal = 22
    external = 2222
    protocol = "tcp"
  }
}

resource "docker_container" "db_vm" {
  name  = "db-vm-1"
  image = "ubuntu:22.04"
  command = ["/bin/bash", "-c", "tail -f /dev/null"]
  networks_advanced {
    name         = docker_network.vm_network.name
    ipv4_address = "198.51.100.20"
  }
  expose = [3306]
}