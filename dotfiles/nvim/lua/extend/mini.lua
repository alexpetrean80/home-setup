return {
  {
    "echasnovski/mini.files",
    opts = {
      options = {
        use_as_default_explorer = true,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Explorer",
      },
      { "<leader>fM", false },
      { "<leader>fm", false },
    },
  },
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },
}
