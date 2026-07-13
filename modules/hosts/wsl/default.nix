{ den, ... }:
{
  den.hosts.x86_64-linux.wsl = {
    wsl.enable = true;
    hostname = "wsl";
    swapSizeGiB = 8;
    users.bruno = { };
  };

  den.aspects.wsl = {
    includes = [
      den.aspects.yubikey
    ];

    nixos = {
      # Enable USBIP passthrough and auto-attach for yubikey
      wsl.usbip = {
        enable = true;
        autoAttach = [
          "1-5"
        ];
      };
      # Udev rules to access USBIP devices as non root user
      services.udev = {
        enable = true;
        extraRules = ''
          SUBSYSTEM=="usb", MODE="0666"
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
        '';
      };
    };
  };
}
