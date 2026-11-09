{ inputs, ... }:
{
  flake-file.inputs = {
    # Official flake (Tier 2 / best-effort): pin a tag or rev, `main` may break.
    # Don't make its nixpkgs follow yours (Python pinned via uv2nix).
    hermes-agent.url = "github:NousResearch/hermes-agent/v0.22.7";
  };

  den.aspects.sun.nixos =
    { config, ... }:

    let
      # ── Topology ────────────────────────────────────────────────────────
      # hermes-sbx  : gateway (Hermes itself, secrets, memory, skills)
      # hermes-exec : where `terminal` commands run (no secrets)
      gw = {
        name = "hermes-sbx";
        veth = "ve-hermes-sbx"; # <= 15 chars
        hostAddress = "10.233.1.1";
        localAddress = "10.233.1.2";
        uidBase = 524288; # container UID 0 -> host 524288
      };
      ex = {
        name = "hermes-exec";
        veth = "ve-hermes-exec"; # <= 15 chars
        hostAddress = "10.233.2.1";
        localAddress = "10.233.2.2";
        uidBase = 589824; # separate range from the gateway
      };

      hermesUid = 2000; # `hermes` inside the gateway container
      agentUser = "agent"; # shell user inside the exec container

      gatewaySshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINO+2CCCRn+AnDmwegUfIi2WygibYIouGjczRU5IK+Hz";

      # ── Shared container base ───────────────────────────────────────────
      baseConfig =
        c:
        { pkgs, lib, ... }:
        {
          nix.enable = false; # no Nix tooling / host daemon use inside
          users = {
            mutableUsers = false;
            allowNoPasswordLogin = true;
          };
          environment.systemPackages = with pkgs; [
            vim
            htop
            gnutar
          ];
          networking = {
            useHostResolvConf = lib.mkForce false;
            nameservers = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };
          system.stateVersion = "26.05";
        };

      privateNets = "10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 100.64.0.0/10, 169.254.0.0/16, 127.0.0.0/8";
    in
    {
      # Use hermes agent binary cache
      nix.settings = {
        extra-substituters = [ "https://hermes-agent.cachix.org" ];
        extra-trusted-public-keys = [
          "hermes-agent.cachix.org-1:jN3pjR50Mxi4SESKC/FIMNM6/LCosvPk2VUwzVvebzU="
        ];
      };

      # ── Secrets (sops-nix) ──────────────────────────────────────────────
      # No idmapped bind mounts: owners are the *host* UIDs of the container users.
      sops = {
        secrets = {
          "hermes/signal-account" = { };
          "hermes/signal-allowed-users" = { };
          "hermes/openrouter-api-key" = { };
          "hermes/gw-ssh-key" = {
            # read by `hermes` inside the gateway
            uid = gw.uidBase + hermesUid;
            gid = gw.uidBase + hermesUid;
            mode = "0400";
          };
          "hermes/exec-host-key" = {
            uid = ex.uidBase;
            gid = ex.uidBase;
            mode = "0400";
          };
        };
        templates."hermes-sbx-secrets.env" = {
          # read by the module's activation as container root
          uid = gw.uidBase;
          gid = gw.uidBase;
          mode = "0400";
          content = ''
            OPENROUTER_API_KEY=${config.sops.placeholder."hermes/openrouter-api-key"}
            SIGNAL_ACCOUNT=${config.sops.placeholder."hermes/signal-account"}
            SIGNAL_ALLOWED_USERS=${config.sops.placeholder."hermes/signal-allowed-users"}
            SIGNAL_HOME_CHANNEL=${config.sops.placeholder."hermes/signal-allowed-users"}
          '';
        };
      };

      # ── Network policy ──────────────────────────────────────────────────
      # Both containers: internet yes; LAN / tailnet / sun no.
      # Only allowed private flow: gateway -> exec on SSH.
      # Own table + hooks: a drop here is final regardless of the main firewall.
      networking.nftables.enable = true;
      networking.nftables.tables.hermes_egress = {
        family = "inet";
        content = ''
          chain forward {
            type filter hook forward priority -10; policy accept;

            # Paquetes inválidos desde los contenedores.
            iifname { "${gw.veth}", "${ex.veth}" } ct state invalid drop

            # Gateway -> Exec: únicamente SSH.
            iifname "${gw.veth}" oifname "${ex.veth}" \
              ip saddr ${gw.localAddress} \
              ip daddr ${ex.localAddress} \
              tcp dport 22 ct state { new, established } accept

            # Respuestas de Exec -> Gateway.
            iifname "${ex.veth}" oifname "${gw.veth}" \
              ip saddr ${ex.localAddress} \
              ip daddr ${gw.localAddress} \
              ct state established,related accept

            # No permitir nuevas conexiones enrutadas
            # desde otras interfaces hacia los contenedores.
            oifname { "${gw.veth}", "${ex.veth}" } \
              ct state new drop

            # Antispoofing IPv4.
            iifname "${gw.veth}" ip saddr != ${gw.localAddress} drop
            iifname "${ex.veth}" ip saddr != ${ex.localAddress} drop

            # Prohibir destinos privados.
            iifname { "${gw.veth}", "${ex.veth}" } \
              ip daddr { ${privateNets} } drop

            # IPv6 completamente deshabilitado en el forwarding
            # hasta configurar una política específica.
            iifname { "${gw.veth}", "${ex.veth}" } \
              meta nfproto ipv6 drop

            # Toda salida restante debe ir por la WAN prevista.
            iifname { "${gw.veth}", "${ex.veth}" } \
              oifname != "lan2s1g" drop
          }

          chain input {
            type filter hook input priority -10; policy accept;
            iifname { "${gw.veth}", "${ex.veth}" } ct state established,related accept
            iifname { "${gw.veth}", "${ex.veth}" } drop
          }
        '';
      };

      systemd.services = {
        "container@${gw.name}" = {
          requires = [ "nftables.service" ];
          after = [ "nftables.service" ];
          serviceConfig = {
            MemoryMax = "3G";
            CPUQuota = "150%";
            TasksMax = 1024;
          };
        };

        "container@${ex.name}" = {
          requires = [ "nftables.service" ];
          after = [ "nftables.service" ];
          serviceConfig = {
            MemoryMax = "2G";
            CPUQuota = "100%";
            TasksMax = 1024;
          };
        };
      };

      # Outbound-only NAT
      networking.nat = {
        enable = true;
        internalInterfaces = [
          gw.veth
          ex.veth
        ];
        externalInterface = "lan2s1g";
      };

      # ══ Gateway container ═══════════════════════════════════════════════
      containers.${gw.name} = {
        autoStart = true;
        ephemeral = false;
        privateNetwork = true;
        privateUsers = gw.uidBase;
        inherit (gw) hostAddress localAddress;

        bindMounts = {
          "/run/hermes-secrets/env" = {
            hostPath = config.sops.templates."hermes-sbx-secrets.env".path;
            isReadOnly = true;
          };
          "/run/hermes-secrets/ssh_key" = {
            hostPath = config.sops.secrets."hermes/gw-ssh-key".path;
            isReadOnly = true;
          };
        };

        extraFlags = [
          "--inaccessible=/nix/var/nix/daemon-socket"
          "--private-users-ownership=auto"
        ];

        config = { pkgs, ... }: {
          imports = [
            (baseConfig gw)
            inputs.hermes-agent.nixosModules.default
          ];

          # Fixed UID so the host-side secret owner matches.
          users.users.hermes.uid = hermesUid;
          users.groups.hermes.gid = hermesUid;

          # Native mode (hardened unit). NOT container.enable: that needs
          # rootful Docker/Podman (+ sudo for podman).
          services.hermes-agent = {
            enable = true;

            environmentFiles = [ "/run/hermes-secrets/env" ];

            # Non-secret only (ends up in the Nix store).
            environment = {
              TERMINAL_SSH_HOST = ex.localAddress;
              TERMINAL_SSH_USER = agentUser;
              TERMINAL_SSH_KEY = "/run/hermes-secrets/ssh_key";

              SIGNAL_HTTP_URL = "http://127.0.0.1:8080";
            };

            settings = {
              model = {
                provider = "openrouter";
                default = "z-ai/glm-5.3-flash";
              };
              # Explicit list instead of "all". Verify names with `hermes tools list`.
              # Left out on purpose: code_execution (second execution path), browser.
              toolsets = [
                "web"
                "skills"
                "memory"
                "todo"
                "terminal"
              ];
              terminal = {
                backend = "ssh";
                cwd = "/home/${agentUser}/workspace"; # path inside hermes-exec
                timeout = 180;
              };
              approvals = {
                mode = "off";
              };
              skills = {
                write_approval = true;
                guard_agent_created = true;
              };
              memory = {
                memory_enabled = true;
                user_profile_enabled = true;
                write_approval = true;
              };
            };

            addToSystemPackages = false;
          };

          programs.ssh.knownHosts."hermes-exec" = {
            hostNames = [ ex.localAddress ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/VKvkyxPfqD/x7HzeXz/yQulpY5pcEcD9ZBcfZUSTZ";
          };

          # Usuario dedicado, independiente de Hermes.
          users.groups.signal-cli = { };
          users.users.signal-cli = {
            isSystemUser = true;
            group = "signal-cli";
            home = "/var/lib/signal-cli";
          };

          # Disponible para vincular la cuenta manualmente.
          environment.systemPackages = with pkgs; [
            signal-cli
          ];

          systemd.services.signal-cli = {
            description = "Signal CLI HTTP Daemon";

            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];

            serviceConfig = {
              Type = "simple";

              User = "signal-cli";
              Group = "signal-cli";

              StateDirectory = "signal-cli";
              StateDirectoryMode = "0700";
              WorkingDirectory = "/var/lib/signal-cli";

              ExecStart = ''
                ${pkgs.signal-cli}/bin/signal-cli \
                  --config /var/lib/signal-cli/data \
                  daemon --http 127.0.0.1:8080 \
                  --no-receive-stdout
              '';

              Restart = "on-failure";
              RestartSec = "5s";

              UMask = "0077";
              NoNewPrivileges = true;
              PrivateTmp = true;
              ProtectSystem = "strict";
              ProtectHome = true;
            };
          };

          # Iniciar Hermes después de intentar iniciar signal-cli.
          systemd.services.hermes-agent = {
            path = [ pkgs.gnutar ];
            wants = [ "signal-cli.service" ];
            after = [ "signal-cli.service" ];
            preStart = ''
              for i in $(${pkgs.coreutils}/bin/seq 1 30); do
                if ${pkgs.curl}/bin/curl \
                  -fsS --max-time 2 \
                  http://127.0.0.1:8080/api/v1/check \
                  >/dev/null 2>&1; then
                  exit 0
                fi

                ${pkgs.coreutils}/bin/sleep 1
              done

              echo "Signal no disponible; Hermes usará su reconexión automática"
              exit 0
            '';
          };

        };
      };

      # ══ Exec container ══════════════════════════════════════════════════
      # No secrets, no memory, no Hermes. Just a shell box with internet.
      containers.${ex.name} = {
        autoStart = true;
        ephemeral = true;
        privateNetwork = true;
        privateUsers = ex.uidBase;
        inherit (ex) hostAddress localAddress;

        bindMounts = {
          "/run/hermes-secrets/ssh_host_ed25519_key" = {
            hostPath = config.sops.secrets."hermes/exec-host-key".path;
            isReadOnly = true;
          };
        };

        extraFlags = [
          "--inaccessible=/nix/var/nix/daemon-socket"
          "--private-users-ownership=auto"
        ];

        config =
          { pkgs, ... }:
          {
            imports = [ (baseConfig ex) ];

            services.openssh = {
              enable = true;
              openFirewall = true;
              settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
                PermitRootLogin = "no";
                AllowUsers = [
                  "${agentUser}@${gw.localAddress}"
                ];
              };
            };

            users.users.${agentUser} = {
              isNormalUser = true;
              home = "/home/${agentUser}";
              createHome = true;
              shell = pkgs.bashInteractive;
              openssh.authorizedKeys.keys = [
                ''restrict,pty,from="${gw.localAddress}" ${gatewaySshPubKey}''
              ];
              packages = with pkgs; [
                git
                ripgrep
                fd
                curl
                jq
                python3
              ];
            };

            # Use the mounted ssh key as host, do not generate a new one
            services.openssh = {
              generateHostKeys = false;
              hostKeys = [
                {
                  type = "ed25519";
                  path = "/run/hermes-secrets/ssh_host_ed25519_key";
                }
              ];
            };

            systemd.tmpfiles.rules = [
              "d /home/${agentUser}/workspace 0750 ${agentUser} users -"
            ];
          };
      };
    };
}
