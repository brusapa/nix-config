{
  den.aspects.bruno.desktop.homeManager = { pkgs, ... }: {

    # Base packages
    home.packages = with pkgs; [
      # Fonts
      jetbrains-mono
      nerd-fonts.jetbrains-mono

      # Utilities
      # bitwarden-desktop # Temporary disabled until electron 39 not used
      veracrypt
      cryptomator
      gimp
      moonlight-qt
      ente-auth
      freecad
      kicad-small
    ];

    programs.spotify-player.enable = true;

    # TODO: Customize obsidian options
    programs.obsidian.enable = true;

    programs.obs-studio.enable = true;
  };
}