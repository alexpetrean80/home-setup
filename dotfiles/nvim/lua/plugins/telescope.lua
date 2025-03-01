return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-ui-select.nvim" },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    {
      "nvim-tree/nvim-web-devicons",
      enabled = true,
    },
  },
  keys = {
    {
      "<leader><leader>",
      "<cmd>Telescope find_files<CR>",
      mode = "n",
      desc = "Find files",
    },
    {
      "<leader>/",
      "<cmd>Telescope live_grep<CR>",
      mode = "n",
      desc = "Live grep",
    },
    {
      "<leader>bb",
      "<cmd>Telescope buffers<CR>",
      mode = "n",
      desc = "Buffers",
    },
    {
      "<leader>gb",
      "<cmd>Telescope git_branches<CR>",
      mode = "n",
      desc = "Branches",
    },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = "move_selection_previous",
            ["<C-j>"] = "move_selection_next",
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>bf", function()
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        previewer = false,
      }))
    end, { desc = "Fuzzy search" })
  end,
}
