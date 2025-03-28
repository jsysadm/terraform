resource "proxmox_lxc" "lxc-instance" {
  target_node  = "pve"                  # -- Keisk į savo Proxmox mazgo/host pavadinimą
  hostname     = "lxc-instance"         # -- Konteinerio vardas
  ostemplate   = "ISO:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" # -- nurodyti LXC template PVE [storage]:vztmpl/[template_name]
  password     = var.lxc_password       # -- kintamasis faile variables.tf, lauko lxc_passwd tipas,  failas terraform.auto.tfvars ir lxc_password  = "slaptažodis"
  unprivileged = true
  cores        = 2
  memory       = 2048
  swap         = 512
  start        = true
  ssh_public_keys = var.PUBLIC_SSH_KEY  # -- kintamasis faile variables.tf, lauko PUBLIC_SSH_KEY tipas, failas terraform.auto.tfvars ir PUBLIC_SSH_KEY  = "pub_key"
  tags = "terraform"                    # -- PVE naudojamas TAG
  rootfs {
    storage = "pve_storage_name"                  # -- disko pavadinimas, kuriame talpinama LXC virtualus diskas
    size    = "8G"
  }

  network {                             # -- network resurso bloką galima kartoti priklausomai nuo reikalingų NIC skaičiaus
    name   = "eth0"                     # -- NIC vardas
    bridge = "vmbr0"                    # -- parinkti Linux Bridge vardą
    ip     = "dhcp"
  }


  features {
    nesting = true
  }
}