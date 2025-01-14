{ pkgs, ... }:

{

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

  # Better cat
  programs.bat = {
    enable = true;
  };

  # Better find (Yazi optional dependency)
  programs.fd = {
    enable = true;
  };

  # JSON sed,awk,etc.. alternative (Yazi optional dependency)
  programs.jq = {
    enable = true;
  };

  # File content searching (Yazi optional dependency)
  programs.ripgrep = {
    enable = true;
  };
 
  # Better resource monitor
  programs.btop = {
    enable = true;
  };

  # Better cd navigation
  programs.zoxide = {
    enable = true;
  };

  # TUI File manager
  programs.yazi = {
    enable = true;
  };

  # General purpose fuzzy finder (Yazi optional dependency)
  programs.fzf = {
    enable = true;
  };

  home.packages = with pkgs; [
    yq
    file # File type detection (Yazi optional dependency)
    ffmpeg # Video thumbnail generation (Yazi optional dependency)
    p7zip # Archive extraction (Yazi optional dependency)
    poppler # PDF thumbnail generator (Yazi optional dependency)
    imagemagick # Image thumbnail generator (Yazi optional dependency)
    wl-clipboard # Clipboard manager (Yazi optional dependency)
  ];

}
