{
  den.aspects.bruno.homeManager = { lib, ... }:
  let
    myHosts = [ "sun" "pluto" "mars" "jupiter" ];
  in 
  {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = lib.genAttrs myHosts (host: {
        HostName = "${host}.brusapa.com";
        User = "bruno";
        ForwardAgent = "yes";
        RemoteForward = {
          bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
          host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
        };
        StreamLocalBindUnlink = "yes";
      });
    };
  };
}
