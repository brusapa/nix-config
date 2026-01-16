# NixOS configuration files

## Execute a remote install

1. Generate the keys for the new host

    ``` bash
    mkdir -p /tmp/<hostname>/etc/ssh
    ssh-keygen -t ed25519 -C <hostname> -f /tmp/<hostname>/etc/ssh/ssh_host_ed25519_key
    nix-shell -p ssh-to-age --run 'cat /tmp/<hostname>/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
    ```

2. Register the age key into sops-nix and update any related secrets file

    ``` bash
    nix-shell -p sops --run "sops updatekeys hosts/common/secrets.yaml"
    ```

3. Set the encryption key for the boot disk
    
    ``` bash
    echo "yoursecretkey" > /tmp/cryptroot.key
    ```

4. Comment the secure boot from installation.

5. Perform the installation over SSH

    ``` bash
    nix run github:nix-community/nixos-anywhere -- \
        --extra-files /tmp/<hostname> \
        --disk-encryption-keys /tmp/cryptroot.key /tmp/cryptroot.key \
        --flake '.#<hostname>' \
        --target-host nixos@<yourip>
    ```

6. Follow the post-installation steps


## Execute a fresh install

1. Choose the passphrase for the storage

    ``` bash
    echo -n "passphrase" > /tmp/cryptroot.key
    ```
    
2. Partition the disc, be careful to substitute the <host>

    
    ``` bash
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --write-efi-boot-entries  --flake 'github:brusapa/nix-config#<host>'
    ```
    
3. Install NixOS, be careful to substitute the <host>

    ``` bash
    sudo nixos-install --root /mnt --flake 'github:brusapa/nix-config#<host>'
    ```

## Post-installation steps

### Secure boot and TPM unlock

[Reference guide](https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde/)

1. Set the secure boot on the BIOS on setup mode
2. Create secure boot the keys

    ``` bash
    nix-shell -p sbctl --run "sudo sbctl create-keys"
    ```

3. Enroll the keys

    ``` bash
    nix-shell -p sbctl --run "sudo sbctl enroll-keys --microsoft"
    ```

4. Perform a nixos rebuild

5. Reboot and verify

    ``` bash
    $ bootctl status
    System:
      Firmware: UEFI 2.80 (American Megatrends 5.27)
      Firmware Arch: x64
      Secure Boot: enabled (user)
      TPM2 Support: yes
      Measured UKI: yes
      Boot into FW: supported
    ```

6. Store the keys on the TPM module (you may have to change the last parameter to point to your encrypted root partition):

    ``` bash
    # systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2
    ```

### Enable Tailscale

``` bash
# tailscale up
```

### Cooler control

``` bash
# sensors-detect --auto
```

