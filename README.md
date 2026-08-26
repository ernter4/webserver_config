# webserver_config

Ansible playbook that provisions my home server: Docker, reverse proxy with
auto-HTTPS, auth, WireGuard VPN, firewall, and backup/restore to an SMB share.

## What it does

`server.yaml`, run against the host in `inventory.ini`:

- creates the `paul` user (SSH key login), disables root/password SSH login
- installs Docker (`geerlingguy.docker` role), WireGuard, UFW, `cifs-utils`, `cron`
- logs in to `ghcr.io`
- sets up WireGuard + a watchdog service
- deploys UFW rules from `files/ufw/`
- mounts the backup share (`//192.168.0.25/backup/server_backup`) at `/mnt/backup`
- renders the compose/config templates from `files/docker/` into `/opt/` and starts:
  - **traefik** – reverse proxy, TLS via Cloudflare DNS challenge
  - **auth** – Authelia (forward-auth) + LLDAP
  - **time** – app behind `time.<apex_domain>`
  - **crates** – app behind `crates.<apex_domain>`, guarded by Authelia
- installs the nightly backup cron job (`/opt/backup.sh`, 2:00 AM)


## Requirements

- Ansible (see `requirements.txt` / `.venv`)
- SSH key at `~/.ssh/id_25519` (see `private_key_file` in `ansible.cfg`) and a
  public key at `~/.ssh/id_ed25519.pub` (installed as authorized_key on the server)
- Vault password in `~/.ssh/ansible-vault.txt` (see `vault_password_file`) to
  decrypt `general_secrets.yml`

```bash
ansible-galaxy role install geerlingguy.docker
ansible-galaxy collection install community.docker ansible.posix
```

## Setup

1. Add the server IP to `inventory.ini`:
   ```ini
   [server]
   1.2.3.4
   ```
2. Edit secrets (Ansible Vault):
   ```bash
   ansible-vault edit general_secrets.yml
   ```
   Required keys: `paul_user_pass`, `github_token`, `smb_backup_password`,
   `wireguard_private_key`, `wireguard_preshared_key`, `traefik_cloudflare_key`,
   `AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD`, `AUTHELIA_SESSION_SECRET`,
   `AUTHELIA_STORAGE_ENCRYPTION_KEY`, `LLDAP_JWT_SECRET`, `LLDAP_KEY_SEED`,
   `LLDAP_LDAP_USER_PASS`, `TIME_SECRET_KEY`.

   Non-secret config (domains, ports, ...) lives in `global_env.yml`.

## Usage

```bash
ansible-playbook server.yaml
```

- `-e restore=true` – after deploy, run `/opt/restore.sh` to restore the
  time/lldap/crates data from `/mnt/backup`.

## Backup / Restore

- `files/backup.sh` stops each stack, copies `data/` to `/mnt/backup/<stack>/`,
  restarts it. Runs daily at 2:00 AM via cron.
- `files/restore.sh` copies data back from `/mnt/backup/` into `/opt/<stack>/data`
  and fixes ownership to `1000:1000`.

## Layout

```
server.yaml            main playbook
inventory.ini          target host(s)
general_secrets.yml    Ansible Vault secrets
global_env.yml          non-secret vars (domains, ports, ...)
files/
  wireguard/           WireGuard config template + watchdog
  ufw/                  firewall rules
  backup.sh, restore.sh
  docker/
    traefik/            reverse proxy + TLS
    auth/                Authelia + LLDAP
    time/, crates/       apps
```
