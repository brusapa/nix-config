{ inputs, ...}:
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  den.aspects.sun.nixos =
    { config, pkgs, ... }:

    let
      containerName = "ci-runner";
    in
    {
      sops.secrets."ci-runner/github-token" = { };

      containers.${containerName} = {
        autoStart = true;
        ephemeral = false; # keep /var (runner home, attic db) across restarts
        timeoutStartSec = "20min";

        privateNetwork = true;
        hostAddress = "10.233.3.1";
        localAddress = "10.233.3.2";

        bindMounts = {
          "/run/secrets/github-token" = {
            hostPath = config.sops.secrets."ci-runner/github-token".path;
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
    };
}
