return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    git = {
      enabled = true,
    },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    {
      "<leader><leader>",
      Snacks.picker.smart,
      desc = "Find files",
    },
    {
      "<leader>/",
      Snacks.picker.grep,
      desc = "Live grep",
    },
    {
      "<leader>bb",
      Snacks.picker.buffers,
      desc = "Buffers",
    },
    {
      "<leader>gb",
      Snacks.picker.git_branches,
      desc = "Branches",
    },
    {
      "gd",
      Snacks.picker.lsp_definitions,
      desc = "Go to definition",
    },
    {
      "gr",
      Snacks.picker.lsp_references,
      desc = "Go to references",
    },
    {
      "gI",
      Snacks.picker.lsp_implementations,
      desc = "Go to implementations",
    },
    {
      "<leader>D",
      Snacks.picker.lsp_type_definitions,
      desc = "Type definition",
    },
    {
      "<leader>sd",
      Snacks.picker.lsp_document_symbols,
      desc = "Document symbols",
    },
    {
      "<leader>sw",
      Snacks.picker.lsp_workspace_symbols,
      "Workspace symbols",
    },
  },
}
