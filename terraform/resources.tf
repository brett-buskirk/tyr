data "digitalocean_ssh_key" "pixelbook" {
  name = "pixelbook"
}

resource "digitalocean_droplet" "tyr_server" {
  image  = var.droplet_image
  name   = "tyr-server"
  region = var.region
  size   = var.droplet_size
  ssh_keys = [
    data.digitalocean_ssh_key.pixelbook.id,
  ]
  tags = [
    "webserver"
  ]
}

resource "digitalocean_firewall" "tyr_firewall" {
  name        = "tyr-firewall"
  droplet_ids = [digitalocean_droplet.tyr_server.id]
  inbound_rule {
    protocol   = "tcp"
    port_range = "22"
    source_addresses = [
      var.inbound_home_ip,
      var.inbound_static_ip
    ]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "public_ip_server" {
  value = digitalocean_droplet.tyr_server.ipv4_address
}
