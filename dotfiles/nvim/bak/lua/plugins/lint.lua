return {
  "mfussenegger/nvim-lint",
  config = function()
    require("lint").linters_by_ft = {
      bash = { "bash" },
      markdown = { "vale" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      python = { "flake8" },
      lua = { "luacheck" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
