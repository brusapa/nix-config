{ pkgs, ... } :
{
  programs.konsole = {
    enable = true;
    defaultProfile = "bruno";
    extraConfig = {
      KonsoleWindow = {
        RememberWindowSize = false;
      };
    };

    profiles.default = {
      name = "bruno";
      command = "${pkgs.fish}/bin/fish";
      colorScheme = "BlackOnWhite";
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 10;
      };
      extraConfig = {
        General = {
          TerminalColumns = 120;
          TerminalRows = 40;
        };
      };
    };
  };
}
