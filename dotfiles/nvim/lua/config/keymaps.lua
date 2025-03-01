-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Splits
vim.keymap.set('n', '<leader>\\', '<cmd>vsplit<CR>', { desc = 'Vertical Split' })
vim.keymap.set('n', '<leader>-', '<cmd>split<CR>', { desc = 'Horizontal Split' })

-- Buffers
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = '[N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = '[P]revious' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[D]elete' })
