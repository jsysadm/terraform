variable "proxmox_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "lxc_password" {
  description = "LXC root slaptažodis"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Kelias iki SSH viešojo rakto"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "PUBLIC_SSH_KEY" {
  
  # -- Public SSH Key, you want to upload to VMs and LXC containers.

  type = string
  sensitive = true
}