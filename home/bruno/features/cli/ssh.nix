{...}: {
  programs.ssh = {
    enable = true;
    matchBlocks  = {
      "nas" = {
        hostname = "nas.brusapa.com";
        user = "bruno";
        forwardAgent = true;
      };
      "venus" = {
        hostname = "venus.brusapa.com";
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
