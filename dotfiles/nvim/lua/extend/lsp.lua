return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = { nushell = {} },
    setup = {
      nushell = function()
        require("lspconfig").nushell.setup({
          cmd = { "nu", "--lsp" },
          filetypes = { "nu" },
          root_dir = require("lspconfig.util").find_git_ancestor,
          single_file_support = true,
        })
      end,
    },
  },
}
