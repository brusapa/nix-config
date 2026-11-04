{
  den.aspects.bruno.cli.homeManager = {
    programs.bash = {
      enable = true;
      shellAliases = {
        la = "ls -la";
      };
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.tmux = {
      enable = true;
    };
  };
}
