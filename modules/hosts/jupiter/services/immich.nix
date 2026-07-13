{ den, ... }:
{
  den.aspects.jupiter = {
    includes = [
      den.aspects.immich
    ];

    nixos = {
      # Allow immich access to ramon directories
      users.users.immich.extraGroups = [ "ramon" ];

      services.immich.mediaLocation = "/zleioa/immich";
    };
  };

}
