return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = { snyk_ls = {} },
    setup = {
      snyk_ls = function()
        require("lspconfig").snyk_ls.setup({})
      end,
    },
  },
}
