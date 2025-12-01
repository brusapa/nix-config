{ ... }:

{

  programs.git = {
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

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        language = "en";
        timeFormat = "2006-01-02T15:04:05-07:00";
        shortTimeFormat = "15:04";
        #nerdFontsVersion: "3";
      };
      git = {
        merging.manualCommit = true;
        autoFetch = false;
        #overrideGpg = true;
        disableForcePushing = true;
      };
      update.method = "never";
      os.editPreset = "nvim";
      disableStartupPopups = true;
    };
  };

}
