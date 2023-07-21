variable "do_token" {
  description = "Digital Ocean API Token"
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of the public key stored on Digital Ocean"
}

variable "inbound_home_ip" {
  description = "IP address of home network for inbound traffic"
}

variable "inbound_static_ip" {
  description = "IP address from vpn provider for inbound traffic"
}

variable "region" {
  description = "Digital Ocean Region"
  default     = "nyc1"
}

variable "droplet_image" {
  description = "Digital Ocean droplet image name"
  default     = "debian-11-x64"
}

variable "droplet_size" {
  description = "Droplet size for server"
  default     = "s-1vcpu-2gb-intel"
}
