{ den, ... }:
{
  den.hosts.x86_64-linux.pluto = {
    role = "server";
    users.bruno = { };
    swapSizeGiB = 2;
  };

  den.aspects.pluto = {
    includes = [
      # Role
      den.aspects.server

      # Other features
      den.aspects.pangolin-server
      den.aspects.beszelAgent
      den.aspects.mail-server
      den.aspects.ntfy
      den.aspects.reverse-proxy
      den.aspects.healthchecks
    ];

    nixos = { lib, ... }: {
      boot = {
        loader.systemd-boot.enable = true;
        initrd.availableKernelModules = [
          "ata_piix"
          "uhci_hcd"
          "virtio_pci"
          "sr_mod"
          "virtio_blk"
        ];
      };

      services.qemuGuest.enable = true;

      nix.settings.trusted-public-keys = [
        "sun:odzSB/QtGOOpZsjB+ARawouX81dLyv1zdeHGE0byKQ4="
      ];

      # Optimise for generation size
      documentation.nixos.enable = false;
      documentation.man.enable = false;
      documentation.doc.enable = false;
      documentation.info.enable = false;

      sops.defaultSopsFile = ./secrets.yaml;

      # Force pangolin (traefik) to only listen at public ip
      services.traefik.staticConfigOptions.entryPoints =
        let
          publicIp = "62.83.118.33";
        in
        {
          web.address = lib.mkForce "${publicIp}:80";
          websecure.address = lib.mkForce "${publicIp}:443";
        };
      # Force caddy to only listen at tailscale ip
      services.caddy.globalConfig =
        let
          tailscaleIp4 = "100.79.211.1";
          tailscaleIp6 = "fd7a:115c:a1e0::af3a:d302";
        in
        ''
          default_bind ${tailscaleIp4} ${tailscaleIp6}
        '';

      reverseProxy.baseDomain = "pluto.brusapa.com";

      # IPs may not yet exist at traefik or caddy start
      boot.kernel.sysctl = {
        "net.ipv4.ip_nonlocal_bind" = 1;
        "net.ipv6.ip_nonlocal_bind" = 1;
      };

      system.stateVersion = "26.05";
    };
  };
}
