{ pkgs, ... }:

let
  ssh-public-key = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBIkuC9ZoZYlmm6xb79mI1OCzh5cGLljSihrlIBzMwjkAAAABHNzaDo= Yubikey 5C";
in {

  home.file.".ssh/id_ed25519_sk.pub".text = 
    "${ssh-public-key}";

  home.file.".ssh/allowed_signers".text = 
    "* ${ssh-public-key}";

  programs.ssh = {
    enable = true;
    forwardAgent = true;
  };

  services.ssh-agent.enable = true;
}