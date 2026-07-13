
{
  den.aspects.bruno = {
    homeManager = {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        extraConfig =
        ''
          " Turn off
          set nofoldenable " Turn off folding (unfold all lines)
          set nowrap " Turn off wrapping
          set nohlsearch " Turn off search highlighting

          " Options
          set foldmethod=indent " Fold based on indentation
          set clipboard=unnamedplus " Use system clipboard for copy and paste
          set number " Show line numbers
          set expandtab " Insert spaces when tab is pressed
          set tabstop=2 " 2 spaces when tab is pressed
          set shiftwidth=2 " 1 tab = 2 spaces
          set smarttab

          " File-based configuration
          autocmd FileType nix setlocal tabstop=2 shiftwidth=2 expandtab
        '';
      };
    };
  };
}