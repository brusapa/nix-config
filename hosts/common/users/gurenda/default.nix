{ inputs, lib, config, pkgs, ... }:

{

  users.users.gurenda = {
    isNormalUser = true;
    description = "Gurenda";
    home = "/home/gurenda";
    createHome = true;
  };

}