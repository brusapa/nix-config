{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    nixd
    alejandra
    devenv
  ];

  programs.direnv.enable = true;

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
}
