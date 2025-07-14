{ inputs, config, pkgs, ... }:
{

  environment.systemPackages = [
    inputs.pangolin-newt.packages.x86_64-linux.pangolin-newt
  ];

  # Import the needed secrets
  sops = {
    secrets = {
      "pangolin-client/id" = {
        sopsFile = ../secrets.yaml;
      };
      "pangolin-client/secret" = {
        sopsFile = ../secrets.yaml;
      };
      "pangolin-client/endpoint" = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates."pangolin-newt.env" = {
      content = ''
        PANGOLIN_ID=${config.sops.placeholder."pangolin-client/id"}
        PANGOLIN_SECRET=${config.sops.placeholder."pangolin-client/secret"}
        PANGOLIN_ENDPOINT="${config.sops.placeholder."pangolin-client/endpoint"}"
      '';
    };
  };

  
  systemd.services.pangolin-newt = {
    description = "Pangolin Newt VPN Client";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ inputs.pangolin-newt.packages.x86_64-linux.pangolin-newt ];
    script = ''
      source ${config.sops.templates."pangolin-newt.env".path}
      exec newt --id "$PANGOLIN_ID" --secret "$PANGOLIN_SECRET" --endpoint "$PANGOLIN_ENDPOINT"
    '';
  };

}