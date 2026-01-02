{ ... }:
{
  imports = [
    ../../../modules/myservices/wallaos.nix
  ];

  wallaos = {
    enable = true;
    version = "4.5.0";
  };
}