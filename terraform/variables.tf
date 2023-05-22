variable "do_token" {
  description = "Digital Ocean API Token"
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of the public key stored on Digital Ocean"
}

variable "region" {
  description = "Digital Ocean Region"
  default     = "sfo3"
}

variable "droplet_image" {
  description = "Digital Ocean droplet image name"
  default     = "debian-11-x64"
}

variable "droplet_size" {
  description = "Droplet size for server"
  default     = "s-1vcpu-2gb-intel"
}
