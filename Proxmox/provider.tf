terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
        }
    }
}

provider "proxmox" {
    pm_api_url          = "https://172.16.1.100:8006/api2/json"   # -- proxmox ipv4
    pm_api_token_id     = "terraform@pam!terraform"                 # -- pve token id "[user]![Token ID]", PVE:Edit: Token: Privilege Separation []
    pm_api_token_secret = var.proxmox_token                         # -- kintamasis faile variables.tf, lauko proxmox_token tipas,  failas terraform.auto.tfvars ir proxmox_token  = "token"
    pm_tls_insecure     = true                                      # -- true jeigu https be sertifikato
}