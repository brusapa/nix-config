{ 
  den.aspects.containers.nixos = 
  {

    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          ipv6 = true;
        };
      };
    };
  };
}