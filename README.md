# Terraform — Proxmox projektas

Trumpas vadovas, kaip naudoti šį Terraform projektą Proxmox VE aplinkoje.

**Struktūra**
- [Proxmox/provider.tf](Proxmox/provider.tf) : Proxmox provider konfigūracija.
- [Proxmox/variables.tf](Proxmox/variables.tf) : Projekto kintamieji.
- [Proxmox/terraform.tfvars](Proxmox/terraform.tfvars) : Pavyzdinės reikšmės (NEĮTRAUKITE slaptų duomenų į viešą repozitoriją).
- [Proxmox/lxc-instance.tf](Proxmox/lxc-instance.tf) : LXC konteinerio resursas.
- [Proxmox/vm-instance.tf](Proxmox/vm-instance.tf) : QEMU VM (klonas iš template).

**Įvadas**
Šis projektas aprašo Proxmox VE infrastruktūros kūrimą naudojant Terraform ir Telmate/proxmox provider. Failai kataloge `Proxmox/` aprašo provider konfigūraciją, kintamuosius ir pavyzdinius resursus (LXC ir VM).

**Reikalavimai**
- Terraform (rekomenduojama naujesnė versija, pvz. >= 1.0).
- Proxmox VE su API prieiga.
- Proxmox API token su reikiamomis teisėmis (pvz. `PVE:VM.Allocate`, `PVE:VM.Config.*`, arba tinkami leidimai pagal jūsų naudojimą).
- SSH raktas jūsų vartotojui (jei norite injectinti viešą raktą į VM/LXC).

**Saugumas**
- `proxmox_token`, `PUBLIC_SSH_KEY` ir `lxc_password` yra pažymėti kaip `sensitive` — niekada nekopijuokite realių reikšmių į viešą repozitoriją.

**Konfigūracija**
1. Nustatykite Proxmox provider informaciją faile [Proxmox/provider.tf](Proxmox/provider.tf) arba per aplinkos kintamuosius. Svarbiausi laukai:
   - `pm_api_url` — Jūsų Proxmox API adresas, pvz. `https://172.16.1.100:8006/api2/json`.
   - `pm_api_token_id` — API token identifikatorius formato `user@pam!tokenid`.
   - `pm_api_token_secret` — token slaptasis raktas (šiuo projekte priskiriamas per `var.proxmox_token`).
   - `pm_tls_insecure` — `true`, jei naudojate savirašį sertifikatą.

2. Užpildykite `Proxmox/terraform.tfvars` (arba eksportuokite per aplinkos kintamuosius `TF_VAR_*`). Pavyzdys faile jau yra:

```
proxmox_token = "example-0b2b-4ee2-be17-36dc47a4e4eb"
lxc_password  = "SuperPassword"
PUBLIC_SSH_KEY = "ssh-rsa AAAA_EXAMPLE_Q9T8qK6Q/U= user@hostname.local"
```

Rekomendacija: vietoj įrašymo į `terraform.tfvars` galite eksportuoti viešą raktą dinamiškai:

```bash
export TF_VAR_PUBLIC_SSH_KEY="$(cat ~/.ssh/id_rsa.pub)"
export TF_VAR_proxmox_token="<your-proxmox-token>"
```

**Naudojimas (pagrindiniai veiksmai)**
1. Inicijuokite Terraform:

```bash
terraform init
```

2. Peržiūrėkite planą:

```bash
terraform plan -var-file=Proxmox/terraform.tfvars
```

3. Taikykite pakeitimus:

```bash
terraform apply -var-file=Proxmox/terraform.tfvars
```

4. Ištrinkite sukurtus resursus (kai reikia):

```bash
terraform destroy -var-file=Proxmox/terraform.tfvars
```

Pastaba: jeigu kintamieji nustatyti per `TF_VAR_*` aplinkos kintamuosius, `-var-file` nėra būtinas.

**Proxmox sekcija**
Ši sekcija aprašo failuose esančius resursus ir svarbiausius parametrus.

- `Proxmox/lxc-instance.tf` — aprašo `proxmox_lxc` resursą:
  - `target_node` — Proxmox mazgo pavadinimas (pakeiskite į savo `pve` / host vardą).
  - `hostname` — konteinerio vardas.
  - `ostemplate` — LXC template lokacija formatu `[storage]:vztmpl/[template_name]`.
  - `password` — `var.lxc_password` (root slaptažodis LXC, jautrus).
  - `unprivileged`, `cores`, `memory`, `swap`, `start` — standartiniai LXC parametrai.
  - `ssh_public_keys` — pridedamas iš `var.PUBLIC_SSH_KEY`.
  - `rootfs` — nustato `storage` ir `size` (pakeiskite `pve_storage_name` į realų storage vardą).
  - `network` — nustatykite `bridge` (pvz. `vmbr0`) arba `ip` (pvz. `dhcp` arba statinį IP).

- `Proxmox/vm-instance.tf` — aprašo `proxmox_vm_qemu` VM iš template:
  - `name` — VM vardas.
  - `target_node` — Proxmox mazgas.
  - `clone` — PVE VM template pavadinimas (klonavimui).
  - `full_clone` — boolean.
  - `cores`, `memory` — resursai.
  - `disk` — `size`, `type`, `storage` (pakeiskite `pve_storage_name`).
  - `network` — `model`, `bridge`, `firewall` ir kt.

**Ką pakeisti prieš diegiant**
- `pm_api_url` ir `pm_api_token_id` faile `Proxmox/provider.tf`.
- `pve_storage_name` → realus storage pavadinimas LXC/VM disko talpai.
- `target_node` → jūsų Proxmox mazgo vardas.
- `ostemplate` ir `clone` → užtikrinkite, kad nurodytas template egzistuoja Proxmox.

**API token kūrimas (trumpai)**
1. Prisijunkite prie Proxmox VE Web UI.
2. Eikite į `Datacenter` → `Permissions` → `API Tokens` (arba vartotojo nustatymuose sukurkite tokeną).
3. Sukurkite tokeną, pažymėkite reikiamas teises ir išsaugokite `Token ID` bei `Secret`.
4. `pm_api_token_id` turi atrodyti kaip `username@realm!tokenid`.

**Dažnos problemos / trikčių šalinimas**
- TLS klaidos: jeigu naudojate self-signed sertifikatą, nustatykite `pm_tls_insecure = true` arba pridėkite CA prie patikimų sertifikatų.
- Autorizacijos klaidos: patikrinkite kad `pm_api_token_id` ir `proxmox_token` yra teisingi ir tokenui suteikti reikiami leidimai.
- Template/Storage errors: įsitikinkite, kad `ostemplate`, `clone` ir `storage` reikšmės egzistuoja jūsų PVE.

**Patarimai**
- Laikykite tik „template“ ir konfigūracijas repozitorijoje — slaptus kintamuosius (token, slaptažodžius) laikykite už .gitignore arba naudokite secret manager.
- Testuokite pakeitimus mažoje aplinkoje prieš diegiant į gamybą.

Jei norite, galiu:
- sugeneruoti pavyzdinį `terraform.tfvars` remiantis jūsų `Proxmox/terraform.tfvars` (su placeholder reikšmėmis),
- arba automatiškai commit'inti šį `README.md` į repozitorijų.

***
Autorius: automatiškai sugeneruotas README pagal `Proxmox/` katalogo .tf failus.
