{ pkgs, ... }:
{
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
}
