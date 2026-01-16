{ ... }:
{
  imports = [
    ../../../modules/myservices/wallaos.nix
    ./pocket-id.nix
  ];

  wallaos = {
    enable = true;
    version = "4.5.0";
  };
}