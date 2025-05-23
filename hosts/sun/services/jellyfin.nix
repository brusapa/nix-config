{ pkgs, ... }:

{
  # Create a user for the jellyfin service
  users.users.jellyfin = {
    uid = 8096;
    group = "multimedia";
    isSystemUser = true;
    extraGroups = [
      "video"
      "render"
    ];
  };

  # Enable HW acceleration for jellyfin
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  hardware = {
    enableAllFirmware = true;
    intel-gpu-tools.enable = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiVdpau
        intel-compute-runtime
        vpl-gpu-rt # QSV on 11th gen or newer
        intel-ocl
      ];
    };
  };

  services.jellyfin = {
    enable = true;
    user = "jellyfin";
    group = "multimedia";
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
