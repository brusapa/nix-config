{ pkgs, ... }:

{
  # Create a group for the jellyfin service
  users.groups.multimedia.gid = 3001;

  # Create a user for the jellyfin service
  users.users.multimedia = {
    uid = 3001;
    group = "multimedia";
    isNormalUser = true;
    #createHome = false;
    extraGroups = [
      "video"
      "render"
    ];
  };

  # Mount the NFS share for multimedia
  fileSystems."/mnt/multimedia" = {
    device = "sun.brusapa.com:/mnt/Temporal/multimedia";
    fsType = "nfs";
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];

  # Enable HW acceleration for jellyfin
  boot.kernelParams = [ 
    "i915.force_probe=4680"
    "i915.enable_guc=3"
    "i915.disable_display=1"
  ];
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
    user = "multimedia";
    group = "multimedia";
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
