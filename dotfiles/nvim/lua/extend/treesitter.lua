return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, { "nu" })
  end,
  dependencies = {
    -- Install official queries and filetype detection
    -- alternatively, see section "Install official queries only"
    { "nushell/tree-sitter-nu" },
  },
  build = ":TSUpdate",
}
