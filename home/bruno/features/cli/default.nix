{ ... }:

{

  imports = [
    ./locale.nix
    ./git.nix
    ./gpg.nix
    ./shell.nix
    ./ssh.nix
    ./neovim.nix
    ./development.nix
  ];
}
