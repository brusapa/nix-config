{
  den.aspects.bruno.homeManager.programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Bruno Santamaria";
        email = "30648587+brusapa@users.noreply.github.com";
      };
      init.defaultBranch = "master";
      # Merge on pull conflicts
      pull.rebase = false;
      # Automatically track remote branch
      push.autoSetupRemote = true;
      # Fetch removed upstream branches
      fetch.prune = true;
    };
    lfs.enable = true;
    signing = {
      signByDefault = true;
      key = "BD6743DAE6ABDF36";
    };
  };
}
