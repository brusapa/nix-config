{ inputs, ...}:
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  den.aspects.sun.nixos =
    { config, pkgs, ... }:

    let
      containerName = "ci-runner";
      atticStorageHostPath = "/zstorage/attic-storage";
    in
    {
      # Static uid shared between the host (which owns the ZFS-backed storage
      # dir) and the container (which runs atticd as this fixed user, instead
      # of a DynamicUser whose uid would change every restart and couldn't own
      # a persistent bind mount).
      users.groups.attic = {
        gid = 397;
      };
      users.users.attic = {
        uid = 397;
        group = "attic";
        isSystemUser = true;
      };

      systemd.tmpfiles.rules = [
        "d ${atticStorageHostPath} 0750 attic attic - -"
      ];

      sops.secrets."ci-runner/github-token" = { };
      sops.secrets."ci-runner/atticd-rsa-secret" = { };
      sops.templates."atticd-secrets.env".content = ''
        ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."ci-runner/atticd-rsa-secret"}
      '';

      containers.${containerName} = {
        autoStart = true;
        ephemeral = false; # keep /var (runner home, attic db) across restarts

        privateNetwork = true;
        hostAddress = "10.233.3.1";
        localAddress = "10.233.3.2";

        bindMounts = {
          # Module's default storage path — just point it at ZFS.
          "/var/lib/atticd/storage" = {
            hostPath = atticStorageHostPath;
            isReadOnly = false;
          };
          "/run/secrets/github-token" = {
            hostPath = config.sops.secrets."ci-runner/github-token".path;
            isReadOnly = true;
          };
          "/run/secrets/atticd.env" = {
            hostPath = config.sops.templates."atticd-secrets.env".path;
            isReadOnly = true;
          };
        };

        config = { pkgs, lib, ... }: {
          environment.systemPackages = with pkgs; [
            git
            attic-client
          ];

          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            extra-substituters = [ "https://cache.numtide.com" ];
            extra-trusted-public-keys = [
              "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            ];
          };

          users.groups.attic = {
            gid = 397;
          };
          users.users.attic = {
            uid = 397;
            group = "attic";
            isSystemUser = true;
          };

          users.users.runner = {
            isSystemUser = true;
            group = "runner";
            home = "/home/runner";
            createHome = true;
            shell = pkgs.bashInteractive;
          };
          users.groups.runner = { };

          services.github-runners.nix-config = {
            enable = true;
            url = "https://github.com/brusapa/nix-config";
            tokenFile = "/run/secrets/github-token";
            replace = true;
            ephemeral = false;
            user = "runner";
            group = "runner";
            extraLabels = [
              "nix-config"
              "sun"
            ];
            extraPackages = [ pkgs.attic-client ];
          };

          services.atticd = {
            enable = true;
            user = "attic";
            group = "attic";
            environmentFile = "/run/secrets/atticd.env";
            settings = {
              listen = "[::]:8080";
              database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
            };
          };

          networking = {
            # Outbound via the host's NAT (set up below); gets a resolver too.
            nameservers = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };
          networking.useHostResolvConf = lib.mkForce false;
          services.resolved = {
            enable = true;
            settings.Resolve.FallbackDNS = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };

          system.stateVersion = "26.05";
        };
      };

      # NAT so the container can reach the internet (GitHub API, nixpkgs
      # substituters). Outbound-only — inbound access to atticd happens via
      # the reverseProxy entry below, not directly.
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-${containerName}" ];
        externalInterface = "lan2s1g";
      };

      reverseProxy.hosts.attic = {
        ip = "10.233.3.2";
        httpPort = 8080;
      };
    };
}
