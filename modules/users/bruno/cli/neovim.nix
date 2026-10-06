{
  den.aspects.bruno.cli = {
    homeManager =
      { pkgs, lib, ... }:
      {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
          extraConfig = ''
            " Turn off
            set nofoldenable " Turn off folding (unfold all lines)
            set nowrap " Turn off wrapping
            set nohlsearch " Turn off search highlighting

            " Options
            set foldmethod=indent " Fold based on indentation
            set number " Show line numbers
            set expandtab " Insert spaces when tab is pressed
            set tabstop=2 " 2 spaces when tab is pressed
            set shiftwidth=2 " 1 tab = 2 spaces
            set smarttab

            " File-based configuration
            autocmd FileType nix setlocal tabstop=2 shiftwidth=2 expandtab
          '';
          initLua = ''
            if vim.env.SSH_TTY then
              vim.g.clipboard = {
                name = "OSC 52",
                copy = {
                  ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
                  ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
                },
                paste = {
                  ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
                  ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
                },
              }
            end

            -- Format Nix files with nixfmt on save, same as `nix fmt`
            vim.api.nvim_create_autocmd("BufWritePre", {
              pattern = "*.nix",
              callback = function(args)
                local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
                local result = vim.system(
                  { "${lib.getExe pkgs.nixfmt}", "-" },
                  { stdin = table.concat(lines, "\n") .. "\n", text = true }
                ):wait()
                if result.code ~= 0 then
                  vim.notify("nixfmt: " .. (result.stderr or ""), vim.log.levels.WARN)
                  return
                end
                local formatted = vim.split(result.stdout, "\n", { plain = true })
                if formatted[#formatted] == "" then
                  table.remove(formatted)
                end
                if not vim.deep_equal(lines, formatted) then
                  local view = vim.fn.winsaveview()
                  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, formatted)
                  vim.fn.winrestview(view)
                end
              end,
            })
          '';
        };
      };
  };
}
