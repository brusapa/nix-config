{ pkgs, inputs, ... }:

let
  containerName = "claude-sbx";
  workspaceHostPath = "/var/lib/${containerName}/workspace";
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Make sure the workspace dir exists on the host with sane ownership.
  systemd.tmpfiles.rules = [
    "d ${workspaceHostPath} 0755 bruno users -"
  ];

  containers.${containerName} = {
    autoStart = true;
    ephemeral = false; # keep container /var (home dirs etc.) across reboots

    privateNetwork = true;
    hostAddress = "10.233.2.1";
    localAddress = "10.233.2.2";

    # Tailscale needs to create/use /dev/net/tun and manage its own routes,
    # which nspawn locks down by default — grant just those two things.
    allowedDevices = [
      { node = "/dev/net/tun"; modifier = "rw"; }
    ];
    additionalCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];

    bindMounts = {
      "/home/bruno/workspace" = {
        hostPath = workspaceHostPath;
        isReadOnly = false;
      };
    };

    config = { pkgs, lib, ... }: {
      # Pull claude-code (and friends) straight from the llm-agents.nix flake's
      # binary cache — no local build required.
      environment.systemPackages = with inputs.llm-agents.packages.${system}; [
        claude-code
      ] ++ (with pkgs; [
        git
        vim
        ripgrep
        fd
        htop
      ]);

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };

      users.mutableUsers = false;
      users.users.bruno = {
        isNormalUser = true;
        home = "/home/bruno";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCdwwDbi4z8NgQeVGjl5dOI9MITbpFGiDOe1SE5QiTO9a548DoMTDdnerY7gkiOXSuPjTSTzVOBT3x28INhMaIQ6MqjgETDvYQlSdnFGZ1Ai1MJl02JOUoE+QiloI2U0qlVoJZrqDcYj1xL6MBTTzZhlJ0FMxFHjFd0HLDCXXMeTcXcAju5aPrrXyR+HcCKqJrYPHKH86gCGzHQVvH6Os26Oe6ykZw2iH/B8ev47Yae/0w3c09DN1uqxeTPr0/SHK6nQc6JrG0cs8V1Nt96WXtQOWqB9R1DpbdWmPY0Hh5t5WrTFdsS54JU8N02soYc6uCLPnxv4i7REzgCwwXJrC6Fxmvu5qBPGTfhi9ES6UlE+RRFxUJ8+EeG8Q2c9xXufsqvqacswc9le7QvsxiC3bQK95BXwc1p9q2ACJtay80OtgnEUMarwdWBzZzwEHtCz9gMnsPh+wwRowZy/cPurvHCtk76qMPhILe4XDs3njw/Lmtpl7zjf/3hILLQlNyELLjXmv9wncGmQs+XZ1Z1htmClQRpzpy83Q1dfuJH2cPOG3OZcouf2tIPUZI+lb/CTtPXndDH1sYs6Sqt1WVk17uwLFq1JIWKhUOYO/z1z/0e6+A0rmeZlMIn2AGW7v96RfRhWP6WSrwdjc5z1ZQYTOuhlcfb2dKMbfd8nxwZ0pRNyw== gpgBruno"
        ];
        shell = pkgs.bashInteractive;
      };

      security.sudo.wheelNeedsPassword = false;

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };

      services.tailscale = {
        enable = true;
        extraUpFlags = [
          "--hostname=${containerName}"
        ];
      };

      networking = {
        # Only reachable over the tailnet + loopback; nothing else gets in.
        firewall.trustedInterfaces = [ "tailscale0" ];

        # Container gets outbound network via the host's NAT (set up below) give it a resolver
        nameservers = [ "1.1.1.1" "1.0.0.1" ];
      };
      networking.useHostResolvConf = lib.mkForce false;
      services.resolved = {
        enable = true;
        settings.Resolve.FallbackDNS = [ "1.1.1.1" "1.0.0.1" ];
      };

      system.stateVersion = "26.05";
    };
  };

  # NAT so the container can reach the internet (needed for the Anthropic API,
  # the Tailscale coordination/DERP servers, and `claude-code` itself) through
  # the private veth link. This does NOT expose the container to your LAN —
  # it's outbound-only NAT, and inbound access happens exclusively via Tailscale.
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-${containerName}" ];
    externalInterface = "lan2s1g";
  };
}
