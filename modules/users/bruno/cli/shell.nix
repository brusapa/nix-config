{
  den.aspects.bruno.homeManager = {
    programs.bash = {
      enable = true;
      shellAliases = {
        la = "ls -la";
      };
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting ""
      '';
    };

    programs.starship = {
      enable = true;
    };

    programs.tmux = {
      enable = true;
    };
  };
}
