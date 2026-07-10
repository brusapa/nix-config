{ den, ...}:
{
  den.aspects.jupiter = {
    includes = [
      den.aspects.frigate
    ];
    nixos = {
      frigate = {
        hwaccel-driver = "radeonsi";
        media-path = "/znvme/frigate";
      };
    };
  };
}