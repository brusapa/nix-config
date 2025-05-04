{ inputs, ... }:

{

  imports = [
    inputs.fw-fanctrl.nixosModules.default
  ];

  programs.fw-fanctrl = {
    enable = true;
    config.defaultStrategy = "lazy";
  };
}