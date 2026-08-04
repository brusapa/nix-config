{ den, ... }:
{
  den.aspects.servarr = {
    includes = [
      den.aspects.configarr
      den.aspects.jackett
      den.aspects.prowlarr
      den.aspects.radarr
      den.aspects.seerr
      den.aspects.sonarr
      den.aspects.unpackerr
    ];

    nixos = {
      # TODO: Create default group for media and set default path
    };

  };
}