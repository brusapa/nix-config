{ pkgs, ... }:

{
  # Create a group for the jellyfin service
  users.groups.multimedia.gid = 3001;

  # Create a user for the jellyfin service
  users.users.multimedia = {
    uid = 3001;
    group = "multimedia";
    isSystemUser = true;
    createHome = false;
  };

  # Mount the NFS share for multimedia
  fileSystems."/mnt/multimedia" = {
    device = "sun.brusapa.com:/mnt/Temporal/multimedia";
    fsType = "nfs";
  };
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];

  # Enable HW acceleration for Jellyfin
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva-vdpau-driver
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      # OpenCL support for intel CPUs before 12th gen
      # see: https://github.com/NixOS/nixpkgs/issues/356535
      intel-compute-runtime-legacy1 
      vpl-gpu-rt # QSV on 11th gen or newer
      intel-ocl # OpenCL support
    ];
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
