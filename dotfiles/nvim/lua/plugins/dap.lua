local map = function(keys, func, desc, mode)
  mode = mode or "n"
  vim.keymap.set(mode, keys, func, { desc = desc })
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")

      map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
      map("<leader>dc", dap.continue, "Continue")
      map("<leader>di", dap.step_into, "Step into")
      map("<leader>do", dap.step_over, "Step over")
      map("<leader>dO", dap.step_out, "Step out")
      map("<leader>dr", dap.repl.open, "Open repl")

      require("dap-go").setup()
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      map("<leader>de", dapui.eval, "Eval")
      map("<leader>dt", dapui.toggle, "Toggle UI")
    end,
  },
}
