data "digitalocean_ssh_key" "heimdall" {
  name = "heimdall"
}

data "digitalocean_ssh_key" "frey" {
  name = "frey"
}

data "digitalocean_ssh_key" "freyja" {
  name = "freyja"
}


resource "digitalocean_volume" "tyr_volume" {
  region                  = "sfo3"
  name                    = "tyr-volume"
  size                    = 5
  initial_filesystem_type = "ext4"
  description             = "tyr volume"
}

resource "digitalocean_droplet" "tyr_server" {
  image  = var.droplet_image
  name   = "tyr-server"
  region = var.region
  size   = var.droplet_size
  ssh_keys = [
    data.digitalocean_ssh_key.heimdall.id,
    data.digitalocean_ssh_key.frey.id,
    data.digitalocean_ssh_key.freyja.id
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
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
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
