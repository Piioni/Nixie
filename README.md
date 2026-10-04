# Nixie

NixOS flake for two hosts, `laptop` and `desktop`. The flake also owns disk partitioning (via
[disko](https://github.com/nix-community/disko)), so a machine is installed **from this repository**,
not installed first and converted later.

| Host | Disk layout | Notes |
|------|-------------|-------|
| `laptop` | 1 GiB EFI + LUKS-encrypted ext4, 32 GiB swapfile for hibernation | Disk pinned in `hosts/laptop/storage.nix` |
| `desktop` | 1 GiB EFI + plain ext4, 20 GiB swapfile | NVIDIA, Steam; disk must be set before installing |

> [!WARNING]
> Installation **erases the whole target disk**. Check the device path twice.

## Before you start

- [ ] A USB stick with the [NixOS minimal ISO](https://nixos.org/download/#nixos-iso) (UEFI boot).
- [ ] Secure Boot disabled in firmware.
- [ ] (Optional) A login password hash in `vars/default.nix` → `initialHashedPassword`.
      Generate it on any machine with Nix and commit it:
      ```bash
      nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt
      ```
      If you skip this, set the password in step 6.

## Install

Run everything as root from the live ISO.

### 1. Connect to the network

```bash
sudo -i
nmcli device wifi connect "<SSID>" --ask   # Ethernet needs nothing
```

### 2. Clone the repository

The live system has no SSH keys, so clone over HTTPS (authenticate with a GitHub token if the
repository is private).

```bash
nix-shell -p git
git clone https://github.com/Piioni/Nixie /tmp/nixie
cd /tmp/nixie
```

### 3. Check the target disk

```bash
ls -l /dev/disk/by-id/ | grep -v part
```

- **Laptop:** confirm the ID matches `device` in `hosts/laptop/storage.nix`.
- **Desktop:** set `device` in `hosts/desktop/storage.nix` to the desktop disk's
  `/dev/disk/by-id/...` path. Use the by-id path, never `/dev/sdX` or `/dev/nvmeXn1`, which can
  change between boots.

### 4. Generate the hardware configuration

`--no-filesystems` is required: disko already declares the filesystems.

```bash
HOST=laptop   # or: desktop
nixos-generate-config --no-filesystems --show-hardware-config \
  > hosts/$HOST/hardware-configuration.nix
git add hosts/$HOST/hardware-configuration.nix
```

> [!IMPORTANT]
> Do not skip `git add`. A `.#host` flake reference only sees files Git knows about; an untracked
> hardware file is silently ignored and the system will not boot correctly.

### 5. Partition, format, and install

```bash
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --flake .#$HOST

nixos-install --flake .#$HOST --no-root-passwd
```

On the laptop, disko asks for the LUKS passphrase. You will type it at every boot.

### 6. Set the login password (if not declared)

Skip this if you set `initialHashedPassword` before installing.

```bash
nixos-enter --root /mnt -c 'passwd piioni'
```

### 7. Place the repository where Home Manager expects it

Live dotfile links (agent configs, skills) point at `/home/piioni/nix-config`.

```bash
cp -a /tmp/nixie /mnt/home/piioni/nix-config
chown -R 1000:100 /mnt/home/piioni/nix-config
reboot
```

## After the first boot

1. Log in through SDDM into the Niri session.
2. Commit the generated hardware file and switch the remote to SSH once your keys are in place:
   ```bash
   cd ~/nix-config
   git commit -m "feat(<host>): add generated hardware configuration" hosts/<host>/hardware-configuration.nix
   git remote set-url origin git@github.com:Piioni/Nixie.git
   ```
3. One-time tool setup:
   - `rustup default stable`
   - Laptop: open Android Studio once so it downloads the SDK into `~/Android/Sdk`.
   - `fvm install` inside each Flutter project.
4. Work through the runtime checklist in `AGENTS.md` → *Operational checklist*.

## Day-to-day

Apply changes from the checkout:

```bash
sudo nixos-rebuild switch --flake ~/nix-config#<host>
```

| Goal | Command |
|------|---------|
| Build without activating | `nixos-rebuild build --flake .#<host>` |
| Try until next reboot | `sudo nixos-rebuild test --flake .#<host>` |
| Validation recipes | `just --list` (see `AGENTS.md`) |
| Roll back | Pick an older generation in the boot menu, or `sudo nixos-rebuild switch --rollback` |

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| Boot drops to an emergency shell or misses the root disk | `hardware-configuration.nix` was not `git add`ed before installing |
| Cannot log in at SDDM | No password set: boot the ISO, clone, run disko with `--mode mount --flake .#<host>`, then repeat step 6 |
| Laptop does not resume from hibernation | Firmware did not keep the `HibernateLocation` EFI variable; add `resume_offset` from `filefrag -v /swapfile` |
