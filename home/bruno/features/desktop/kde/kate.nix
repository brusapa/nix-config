{ ... }: 
{
  programs.kate = {
    enable = true;
    editor = {
      font = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
      indent = {
        replaceWithSpaces = true;
        width = 2;
      };
      tabWidth = 2;
    };
  };
}