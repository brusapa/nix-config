# NixOS configuration files

## Installation

Before starting the installation, make sure that the system has secure boot enabled and it is in setup mode.

### Remote install (recommended)

1. Generate the keys for the new host

    ``` bash
    TARGET-HOSTNAME=<hostname> && \
    mkdir -p /tmp/${TARGET-HOSTNAME}/etc/ssh && \
    ssh-keygen -q -t ed25519 -C "${TARGET-HOSTNAME}" -N "" -f /tmp/${TARGET-HOSTNAME}/etc/ssh/ssh_host_ed25519_key && \
    nix-shell -p ssh-to-age --run "cat /tmp/${TARGET-HOSTNAME}/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age"
    ```

2. Register the age key into sops-nix and update any related secrets file

    ``` bash
    nix-shell -p sops --run "sops updatekeys modules/users/secrets.yaml modules/hosts/${TARGET-HOSTNAME}/secrets.yaml"
    ```

3. Set the encryption key for the boot disk
    
    ``` bash
    echo "<passphrase>" > /tmp/${TARGET-HOSTNAME}-encryption.key
    ```

4. Perform the installation over SSH

    ``` bash
    TARGET-IP=<ip> && \
    nix run github:nix-community/nixos-anywhere -- \
        --extra-files /tmp/${TARGET-HOSTNAME} \
        --disk-encryption-keys /tmp/${TARGET-HOSTNAME}-encryption.key /tmp/cryptroot.key \
        --flake '.#${TARGET-HOSTNAME}' \
        --target-host nixos@${TARGET-IP}
    ```

5. Follow the post-installation steps

### Local install from live media

1. Set the encryption key for the boot disk

    ``` bash
    echo -n "<passphrase>" > /tmp/cryptroot.key
    ```
    
2. Install the system, be careful to substitute the <hostname>

    
    ``` bash
    TARGET-HOSTNAME=<hostname> && \
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --write-efi-boot-entries  --flake 'github:brusapa/nix-config#${TARGET-HOSTNAME}' && \
    sudo nixos-install --root /mnt --flake 'github:brusapa/nix-config#${TARGET-HOSTNAME}'
    ```

## Post-installation steps

### TPM disk unlock

1. Ensure secure boot is working properly

    ``` bash
    bootctl status
    ```
    ``` bash
    System:
      Firmware: UEFI 2.80 (American Megatrends 5.27)
      Firmware Arch: x64
      Secure Boot: enabled (user)
      TPM2 Support: yes
      Measured UKI: yes
      Boot into FW: supported
    ```

2. Store the keys on the TPM module:

    ``` bash
    sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 "$(sudo cryptsetup status cryptroot | awk '/device:/{print $2}')"
    ```

### Enable Tailscale

``` bash
sudo tailscale up
```
