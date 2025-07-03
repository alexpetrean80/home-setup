vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
 
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Enable Treesitter highlight on startup',
  group = vim.api.nvim_create_augroup('treesitter-highlight-on-startup', { clear = true }),
  callback = function()
    vim.cmd('TSEnable highlight')
  end,
})
