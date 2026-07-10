{
  den.aspects.amd-gpu = {
    nixos = {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}