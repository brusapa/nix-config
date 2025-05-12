{ inputs, lib, pkgs, config, ... }:

{
  xdg.desktopEntries = {
    gaming-resolution = {
      name = "GamingResolution";
      exec = "kscreen-doctor output.DP-3.mode.2560x1440@120";
      terminal = false;
      type = "Application";
      categories = [ "Application" ];
    };
    native-resolution = {
      name = "NativeResolution";
      exec = "kscreen-doctor output.DP-3.mode.5120x1440@120";
      terminal = false;
      type = "Application";
      categories = [ "Application" ];
    };
  };
}
