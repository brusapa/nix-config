# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
# }

# To store the passphrase for luks
# echo -n "passphrase" > /tmp/cryptroot.key
{ inputs, config, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENX0W106228H";
        type = "disk";
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
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                settings.allowDiscards = true;
                passwordFile = "/tmp/cryptroot.key";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63GKXX";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        }
      };
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000VN006-3CW104_ZW63GZK3";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        }
      };
    };
    zpool = {
      zstorage = {
        type = "zpool";
        mode = "mirror";
        # Workaround: cannot import 'zstorage': I/O error in disko tests
        options.cachefile = "none";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/mnt/storage";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zstorage@blank$' || zfs snapshot zstorage@blank";

        datasets = {
          multimedia = {
            type = "zfs_fs";
            mountpoint = "/mnt/storage/multimedia";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}