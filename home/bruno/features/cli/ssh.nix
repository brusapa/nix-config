{...}: {
  programs.ssh = {
    enable = true;
    matchBlocks  = {
      "sun" = {
        hostname = "sun.brusapa.com";
        user = "bruno";
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
            host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
          }
        ];
        extraOptions.StreamLocalBindUnlink = "yes";
      };
      "mars" = {
        hostname = "mars.brusapa.com";
        user = "bruno";
        forwardAgent = true;
        remoteForwards = [
          {
            bind.address = ''/run/user/1000/gnupg/S.gpg-agent'';
            host.address = ''/run/user/1000/gnupg/S.gpg-agent.extra'';
          }
        ];
        extraOptions.StreamLocalBindUnlink = "yes";
      };
    };
  };
}
