{
  inputs,
  ...
}:
{
  flake.modules.nixos.sun = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      systemd-boot
    ];
  };
}