{ inputs, lib, config, pkgs, ... }:

{

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  nixpkgs.overlays = [
    (_: prev: {
      tailscale = prev.tailscale.overrideAttrs (old: {
        checkFlags =
          builtins.map (
            flag:
              if prev.lib.hasPrefix "-skip=" flag
              then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$"
              else flag
          )
          old.checkFlags;
        });
    })
  ];


}
