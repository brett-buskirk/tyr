resource "digitalocean_volume" "tyr_volume" {
  region                  = "sfo3"
  name                    = "tyr-volume"
  size                    = 10
  initial_filesystem_type = "ext4"
  description             = "tyr volume"
}

resource "digitalocean_droplet" "tyr_server" {
  image  = "debian-11-x64"
  name   = "tyr-server"
  region = "sfo3"
  size   = "s-1vcpu-1gb-intel"
  ssh_keys = [
    var.ssh_key_fingerprint
  ]
}

resource "digitalocean_volume_attachment" "tyr_volume" {
  droplet_id = digitalocean_droplet.tyr_server.id
  volume_id  = digitalocean_volume.tyr_volume.id
}

resource "digitalocean_firewall" "tyr_firewall" {
  name        = "tyr-firewall"
  droplet_ids = [digitalocean_droplet.tyr_server.id]
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

output "public_ip_server" {
  value = digitalocean_droplet.tyr_server.ipv4_address
}
