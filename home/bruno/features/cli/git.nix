{ ... }:

{

  programs.git = {
    enable = true;
    userName = "Bruno Santamaria";
    lfs.enable = true;
    userEmail = "30648587+brusapa@users.noreply.github.com";
    signing = {
       signByDefault = true;
       key = "BD6743DAE6ABDF36";
    };
    extraConfig = {
      init.defaultBranch = "master";
      # Merge on pull conflicts
      pull.rebase = false;
      # Automatically track remote branch
      push.autoSetupRemote = true;
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
        disableForcePushing = true;
      };
      update.method = "never";
      os.editPreset = "nvim";
      disableStartupPopups = true;
    };
  };

}
