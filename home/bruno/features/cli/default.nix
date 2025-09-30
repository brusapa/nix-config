{ ... }:

{

  imports = [
    ./locale.nix
    ./git.nix
    ./gpg.nix
    ./shell.nix
    ./ssh.nix
    ./nvf.nix
    ./development.nix
  ];
}
