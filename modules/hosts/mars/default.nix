{ den, ... }:
{
  den.hosts.x86_64-linux.mars = {
    role = "workstation";
    users = {
      bruno = { };
      gurenda = { };
    };
    swapSizeGiB = 64;
  };

  den.aspects.mars = {
    includes = [
      # Role
      den.aspects.workstation

      # Other features
      den.aspects.gaming
      den.aspects.sunshine

      # Hardware
      den.aspects.amd-cpu
      den.aspects.amd-gpu
      den.aspects.bluetooth
      den.aspects.logitech
      den.aspects.keychron
      den.aspects.brother-printer
    ];

    nixos =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        # TODO: Replace the following with the disko config
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/7ab38f8e-d1e3-48be-9e34-89ba94380a2d";
          fsType = "ext4";
        };
        boot.initrd.luks.devices."cryptroot".device =
          "/dev/disk/by-uuid/cdba122e-11e0-4d6a-8bd6-3c7a0bd47b3a";
        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/AB24-BEBF";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };

        # Add EC sensors for asus motherboards
        boot.extraModulePackages = with config.boot.kernelPackages; [ asus-ec-sensors ];
        environment.systemPackages = with pkgs; [
          lm_sensors
          furmark
        ];

        # Unique host identifier used for ZFS
        networking.hostId = "c66a2250";

        # Enable Wake On Lan
        networking.interfaces.eno1.wakeOnLan.enable = true;

        # GPU
        # Control GPU fans and undervolt
        hardware.amdgpu.overdrive.enable = true;
        services.lact = {
          enable = true;
          settings = {
            version = 5;
            daemon = {
              log_level = "info";
              admin_group = "wheel";
              disable_clocks_cleanup = false;
            };
            apply_settings_timer = 5;
            gpus = {
              "1002:747E-1DA2:D475-0000:03:00.0" = {
                fan_control_enabled = false;
                pmfw_options = {
                  zero_rpm = true;
                };
                performance_level = "auto";
                voltage_offset = -75;
              };
            };
            current_profile = null;
            auto_switch_profiles = false;
          };
        };
      };
  };
}
