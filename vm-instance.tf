resource "proxmox_vm_qemu" "vm-instance" {
    name                = "vm-instance" # -- VM vardas
    target_node         = "pve"     # -- Keisk į savo Proxmox mazgo/host pavadinimą
    clone               = "template-name"  # -- PVE VM template pavadinimas
    full_clone          = true          # -- klonavimo tipas
    cores               = 2
    memory              = 2048

    disk {
        size            = "50G"         # -- klonuoto VM disko talpa turi sutapti su PVE VM template
        type            = "scsi"
        storage         = "pve_storage_name"      # -- disko pavadinimas, kuriame talpinama VM virtualus diskas
        discard         = "on"
    }

    network {                           # -- network resurso bloką galima kartoti priklausomai nuo reikalingų NIC skaičiaus
        model     = "virtio"
        bridge    = "vmbr0"             # -- parinkti Linux Bridge vardą
        firewall  = false
        link_down = false
    }

}