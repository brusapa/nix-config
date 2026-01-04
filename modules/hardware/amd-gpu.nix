{ ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Control GPU fans and undervolt
  hardware.amdgpu.overdrive.enable = true;
  services.lact = {
    enable = true;
  };

}