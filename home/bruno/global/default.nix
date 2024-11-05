{ lib, config, ...}: {
  imports = [
    ../features/cli
  ];

  home = {
    # This needs to actually be set to your username
    username = lib.mkDefault "bruno";
    homeDirectory = "/home/${config.home.username}";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.05";
  };
}
