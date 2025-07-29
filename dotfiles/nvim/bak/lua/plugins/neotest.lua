return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-go",
  },
  config = function()
    -- get neotest namespace (api call creates or returns namespace)
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    local neotest = require("neotest")

    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)
    neotest.setup({
      adapters = {
        require("neotest-go")({
          experimental = {
            test_table = true,
          },
        }),
      },
    })

    local with_summary = function(cb)
      return function()
        cb()
        neotest.summary.open()
      end
    end

    vim.keymap.set("n", "<leader>tt", with_summary(neotest.run.run), { desc = "Run nearest" })
    vim.keymap.set(
      "n",
      "<leader>tf",
      with_summary(function()
        neotest.run.run(vim.fn.expand("%"))
      end),
      { desc = "Test file" }
    )
    vim.keymap.set(
      "n",
      "<leader>tp",
      with_summary(function()
        neotest.run.run(vim.fn.getcwd())
      end),
      { desc = "Test project" }
    )
    vim.keymap.set(
      "n",
      "<leader>td",
      with_summary(function()
        neotest.run.run({ strategy = "dap" })
      end),
      { desc = "Debug nearest" }
    )
    vim.keymap.set("n", "<leader>ts", neotest.summary.toggle, { desc = "Toggle summary" })
  end,
}
