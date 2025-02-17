return {
  "Mofiqul/vscode.nvim",
  config = function()
    local colours = require("vscode.colors").get_colors
    require("vscode").setup({
      italic_comments = true,
    })
  end,
}
