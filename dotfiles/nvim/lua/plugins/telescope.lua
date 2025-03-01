return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    {
      "nvim-tree/nvim-web-devicons",
      enabled = vim.g.have_nerd_font,
    },
  },

  -- vim.keymap.set('n', '<leader>gb', branches, { desc = '[B]ranches' })
  keys = {
    {
      "<leader><leader>",
      require("telescope.builtin").find_files,
      mode = "n",
      desc = "Find files",
    },
    {
      "<leader>/",
      require("telescope.builtin").live_grep,
      mode = "n",
      desc = "Live grep",
    },
    {
      "<leader>bb",
      require("telescope.builtin").buffers,
      mode = "n",
      desc = "Buffers",
    },
    {
      "<leader>bf",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(
          require("telescope.themes").get_dropdown({ previewer = false })
        )
      end,
      mode = "n",
      desc = "Fuzzy search",
    },
    {
      "<leader>gb",
      require("telescope.builtin").git_branches,
      mode = "n",
      desc = "Branches",
    },
  },
  config = function()
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")
  end,
}
