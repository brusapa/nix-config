{inputs, lib, ...}:
{
  den.aspects.bruno = {
    homeManager = {
      imports = [
        inputs.nvf.homeManagerModules.default
      ];
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

            lsp.enable = true;
            languages = {
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
              typescript.enable = true;
            };
          };
        };
      };
    };
  };
}