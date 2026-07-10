{
  den.aspects.gnupg-agent.nixos = { pkgs, ... }: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableExtraSocket = true;
      settings = {
        default-cache-ttl = 60;
        max-cache-ttl = 120;
      };
    };
  };
}