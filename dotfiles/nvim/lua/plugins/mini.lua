return { -- Collection of various small independent plugins/modules
  "echasnovski/mini.nvim",
  lazy = false,
  keys = {
    {
      "<leader>e",
      function()
        require("mini.files").open(vim.uv.cwd(), true)
      end,
      desc = "Explorer",
    },
  },
  config = function()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.comment").setup()
    require("mini.files").setup({
      use_icons = true,
      use_as_default_explorer = true,
    })
    require("mini.git").setup()
    require("mini.pairs").setup()
    require("mini.extra").setup()
    require("mini.surround").setup()
		require('mini.icons').setup()

    -- part of me wants to swap Telescope with this, but it's less polished/more minimal
    require("mini.pick").setup()

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionRename",
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })

    local statusline = require("mini.statusline")
    statusline.setup({ use_icons = vim.g.have_nerd_font })
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return "%2l:%-2v"
    end
  end,
}
