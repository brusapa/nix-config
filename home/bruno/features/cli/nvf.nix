{ inputs, ... }:

{

  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        theme = {
          enable = true;
          name = "catppuccin";
          style = "latte";
        };

        options = {
          shiftwidth = 2;
          expandtab = true;
          smarttab = true;
        };

        lineNumberMode = "number";
        preventJunkFiles = true;

        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;

        languages = {
          enableLSP = true;
          enableTreesitter = true;

          bash.enable = true;
          clang.enable = true;
          csharp.enable = true;
          css.enable = true;
          html.enable = true;
          markdown.enable = true;
          nix.enable = true;
          python.enable = true;
          rust.enable = true;
          ts.enable = true;
        };
      };
    };
  };
}
