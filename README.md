# NixOS configuration files

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
    # sbctl create-keys
    ```

3. Enroll the keys

    ``` bash
    # sbctl enroll-keys -- --microsoft
    ```

4. Reboot and verify

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

5. Store the keys on the TPM module (you may have to change the last parameter to point to your encrypted root partition):

    ``` bash
    # systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2
    ```

### Import SSH resident key

``` bash
$ cd ~/.ssh
$ ssh-keygen -K
$ mv id_ed25519_sk_* id_ed25519_sk
```

### Enable Tailscale

``` bash
# tailscale up
```

### Cooler control

``` bash
# sensors-detect --auto
```

