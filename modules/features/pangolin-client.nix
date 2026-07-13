{
  den.aspects.pangolin-client.nixos = 
    { config, ... }:
    {
      # Import the needed secrets
      sops = {
        secrets = {
          "pangolin-client/id" = { };
          "pangolin-client/secret" = { };
          "pangolin-client/endpoint" = { };
        };
        templates."pangolin-newt.env" = {
          content = ''
            NEWT_ID=${config.sops.placeholder."pangolin-client/id"}
            NEWT_SECRET=${config.sops.placeholder."pangolin-client/secret"}
            PANGOLIN_ENDPOINT="${config.sops.placeholder."pangolin-client/endpoint"}"
          '';
        };
      };

      services.newt = {
        enable = true;
        environmentFile = config.sops.templates."pangolin-newt.env".path;
      };
    };
}