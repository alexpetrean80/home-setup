return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = { enabled = false },
    dim = { enabled = true },
    explorer = { enabled = false },
    git = {
      enabled = true,
    },
    image = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    rename = { enabled = true },
    scope = { enabled = true },
    scratch = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = false },
    words = { enabled = true },
  },
  keys = {
    {
      "<leader><leader>",
      "<cmd>lua Snacks.picker.smart()<CR>",
      desc = "Find files",
    },
    {
      "<leader>/",
      "<cmd>lua Snacks.picker.grep()<CR>",
      desc = "Live grep",
    },
    {
      "<leader>bb",
      "<cmd>lua Snacks.picker.buffers()<CR>",
      desc = "Buffers",
    },
    {
      "<leader>gb",
      "<cmd>lua Snacks.picker.git_branches()<CR>",
      desc = "Branches",
    },
    {
      "gd",
      "<cmd>lua Snacks.picker.lsp_definitions()<CR>",
      desc = "Go to definition",
    },
    {
      "gr",
      "<cmd>lua Snacks.picker.lsp_references()<CR>",
      desc = "Go to references",
    },
    {
      "gI",
      "<cmd>lua Snacks.picker.lsp_implementations()<CR>",
      desc = "Go to implementations",
    },
    {
      "<leader>D",
      "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>",
      desc = "Type definition",
    },
    {
      "<leader>sd",
      "<cmd>lua Snacks.picker.lsp_document_symbols()<CR>",
      desc = "Document symbols",
    },
    {
      "<leader>sw",
      "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>",
      "Workspace symbols",
    },
    {
      "<leader>.",
      "<cmd>lua Snacks.scratch()<CR>",
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      "<cmd>lua Snacks.scratch.select()<CR>",
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>gB",
      "<cmd>lua Snacks.git.blame_line()<CR>",
      desc = "Blame line",
    },
    {
      "<leader>gp",
      "<cmd>lua Snacks.terminal.open('gh pr create')<CR>",
      desc = "Open PR",
    },

    {
      "<leader>gw",
      "<cmd>lua Snacks.terminal.open('gh pr view')<CR>",
      desc = "View PR",
    },
    {
      "<leader>gd",
      "<cmd>lua Snacks.terminal.open('gh dash')<CR>",
      desc = "GH Dash",
    },
    {
      "<leader>gg",
      "<cmd>lua Snacks.lazygit()<CR>",
      desc = "Lazygit",
    },
  },
}
