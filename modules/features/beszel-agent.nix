{
  den.aspects.beszelAgent = {
    nixos = { config, ...}: {

      sops =  {
        secrets = {
          "beszel-agent/token" = { };
          "beszel-agent/key" = { };
        };
        templates."beszel-agent-secrets.env".content = ''
          KEY=${config.sops.placeholder."beszel-agent/key"}
          TOKEN=${config.sops.placeholder."beszel-agent/token"}
        '';
      };

      services.beszel.agent = {
        enable = true;
        smartmon.enable = true;
        environment = {
          DISABLE_SSH="true";
          HUB_URL="https://beszel.brusapa.com";
        };
        environmentFile = config.sops.templates."beszel-agent-secrets.env".path;
      };
    };
  };
}