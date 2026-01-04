# Set the secret key in /tmp/secret.key

{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT1000E100SSD8_2533EADB233D";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
        };
        options.ashift = "12";
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///tmp/secret.key";
            };
            mountpoint = "/";
          };
          "root/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };

          # README MORE: https://wiki.archlinux.org/title/ZFS#Swap_volume
          "root/swap" = {
            type = "zfs_volume";
            size = "32G";
            content = {
              type = "swap";
            };
            options = {
              volblocksize = "4096";
              compression = "zle";
              logbias = "throughput";
              sync = "always";
              primarycache = "metadata";
              secondarycache = "none";
            };
          };
        };
      };
    };
  };
}
