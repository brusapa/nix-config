{
  den.aspects.amd-gpu = {
    nixos = {
      hardware = {
        amdgpu.initrd.enable = true;
        graphics = {
          enable = true;
          enable32Bit = true;
        };
      };
    };
  };
}
