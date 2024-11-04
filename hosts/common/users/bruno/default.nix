{ inputs, lib, config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.users.gid = 100;

  users.users.bruno = {
    isNormalUser = true;
    description = "Bruno";
    uid = 1000;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBIkuC9ZoZYlmm6xb79mI1OCzh5cGLljSihrlIBzMwjkAAAABHNzaDo= Yubikey 5C"
    ];
    home = "/home/bruno";
    createHome = true;
  };

  nix.settings.trusted-users = [ "bruno" ];
}