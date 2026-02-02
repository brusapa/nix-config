{
  flake.modules.homeManager.shell =
    {
      config,
      ...
    }:
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting ""
        '';
      };

      programs.starship = {
        enable = true;
      };

      programs.bash = {
        enable = true;
        enableCompletion = true;
        shellAliases = {
          la = "ls -la";
        };
      };
    };
}