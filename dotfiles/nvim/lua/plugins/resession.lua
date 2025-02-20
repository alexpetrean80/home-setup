local function get_session_name()
  local name = vim.fn.getcwd()
  local branch = vim.trim(vim.fn.system("git branch --show-current"))
  if vim.v.shell_error == 0 then
    return name .. branch
  else
    return name
  end
end

return {
  "stevearc/resession.nvim",
  opts = {},
  init = function()
    local resession = require("resession")

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Only load the session if nvim was started with no args
        if vim.fn.argc(-1) == 0 then
          resession.load(get_session_name(), { dir = "dirsession", silence_errors = true })
        end
      end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        resession.save(get_session_name(), { dir = "dirsession", notify = false })
      end,
    })
  end,

  keys = {
    {
      "<leader>Rs",
      function()
        require("resession").save()
      end,
      desc = "Save session",
    },
    {
      "<leader>Rl",
      function()
        require("resession").load()
      end,
      desc = "Load session",
    },
    {
      "<leader>Rd",
      function()
        require("resession").delete()
      end,
      desc = "Delete session",
    },
  },
}
