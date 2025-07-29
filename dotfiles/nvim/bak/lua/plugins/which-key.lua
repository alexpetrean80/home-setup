return {
  "folke/which-key.nvim",
  event = "VimEnter",
  opts = {
    delay = 0,
    preset = "helix",
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = {},
    },
    spec = {
      { "<leader>b", group = "Buffers", mode = { "n" } },
      { "<leader>d", group = "Debug", mode = { "n" } },
      { "<leader>g", group = "Git", mode = { "n" } },
      { "<leader>s", group = "Symbols", mode = { "n" } },
    },
  },
}
