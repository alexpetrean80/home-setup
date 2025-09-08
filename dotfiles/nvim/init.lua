vim.cmd([[set mouse=]])

local function install_deps()
	local github_url = "https://github.com/"

	vim.pack.add({
		{
			src = github_url .. "nvim-treesitter/nvim-treesitter",
			version = "master",
		},
		{ src = github_url .. "neovim/nvim-lspconfig" },
		{
			src = github_url .. "catppuccin/nvim",
			name = "catppuccin",
		},
		{ src = github_url .. "christoomey/vim-tmux-navigator" },
		{ src = github_url .. "folke/which-key.nvim" },
		{ src = github_url .. "HiPhish/rainbow-delimiters.nvim" },
		{
			src = github_url .. "echasnovski/mini.nvim",
			version = "main",
		},
		{ src = github_url .. "mfussenegger/nvim-dap" },
		{ src = github_url .. "leoluz/nvim-dap-go" },
		{ src = github_url .. "igorlfs/nvim-dap-view" },
		{ src = github_url .. "theHamsta/nvim-dap-virtual-text" },
		{ src = github_url .. "vim-test/vim-test" },
		{ src = github_url .. "stevearc/conform.nvim" },
		{ src = github_url .. "f-person/git-blame.nvim" },
	})
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.opt.winborder = "rounded"
vim.opt.wrap = true
vim.opt.tabstop = 8
vim.opt.swapfile = false
vim.opt.laststatus = 3
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.backup = false
vim.opt.autoread = true

vim.o.clipboard = "unnamedplus"

install_deps()

vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect", "popup", "preview" }

vim.api.nvim_set_keymap(
	"i",
	"<C-space>",
	"vim.lsp.completion.trigger()",
	{ noremap = true, silent = true, expr = true, desc = "Trigger LSP Completion" }
)
vim.api.nvim_set_keymap(
	"i",
	"<C-n>",
	'pumvisible() ? "<C-n>":"<C-n>"',
	{ noremap = true, silent = true, expr = true, desc = "Next completion item" }
)
vim.api.nvim_set_keymap(
	"i",
	"<C-p>",
	'pumvisible() ? "<C-p>":"<C-p>"',
	{ noremap = true, silent = true, expr = true, desc = "Previous completion item" }
)
vim.api.nvim_set_keymap(
	"i",
	"<CR>",
	'pumvisible() ? "<C-y>":"<CR>"',
	{ noremap = true, silent = true, expr = true, desc = "Accept completion or new line" }
)
vim.api.nvim_set_keymap(
	"i",
	"<Tab>",
	'pumvisible() ?"<C-n>":"<Tab>"',
	{ noremap = true, silent = true, expr = true, desc = "Next completion item or tab" }
)
vim.api.nvim_set_keymap(
	"i",
	"<S-Tab>",
	'pumvisible() ? "<C-p>":"<S-Tab>"',
	{ noremap = true, silent = true, expr = true, desc = "Previous completion item or shift-tab" }
)

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true)
		end
		-- whatever other lsp config you want
	end,
})

require("mini.completion").setup()
require("mini.comment").setup()
require("mini.statusline").setup()
require("mini.files").setup()
require("mini.pick").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.icons").setup()
require("mini.indentscope").setup()
require("mini.move").setup()
require("mini.notify").setup()
require("mini.extra").setup()
require("which-key").setup({
	preset = "helix",
	delay = 0,
	show_help = false,
	show_keys = true,
	icons = {
		mappings = false,
	},
	win = {
		border = "none",
	},
	spec = {
		{ "<leader>b", group = "Buffers", mode = "n" },
		{ "<leader>g", group = "Git", mode = "n" },
		{ "<leader>d", group = "Debug", mode = "n" },
		{ "<leader>l", group = "LSP", mode = "n" },
		{ "<leader>t", group = "Testing", mode = "n" },
	},
})

require("dap-go").setup()
require("nvim-dap-virtual-text").setup()
vim.cmd('let test#strategy = "neovim_sticky"')

local conform = require("conform")
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofmt", "golines", "goimport" },
		nix = { "alejandra" },
	},
})

local keymap = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

keymap("n", "<leader>\\", "<cmd>vsplit<CR>", "Vertical split")
keymap("n", "<leader><leader>", MiniPick.builtin.files, "Files")
keymap("n", "<leader>e", MiniFiles.open, "Explorer")
keymap("n", "<leader>/", MiniPick.builtin.grep_live, "Live grep")
keymap("n", "<leader>x", vim.diagnostic.setqflist, "Diagnostics")

-- LSP
keymap("n", "<leader>la", vim.lsp.buf.code_action, "Code Actions")
keymap("n", "<leader>lf", conform.format, "Format")
keymap("n", "<leader>ld", vim.lsp.buf.definition, "Go to definition")
keymap("n", "<leader>lD", vim.lsp.buf.declaration, "Go to declaration")
keymap("n", "<leader>lr", function()
	MiniExtra.pickers.lsp({ scope = "references" })
end, "LSP References")

-- Navigation
vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<CR>")

-- Buffers
keymap("n", "<leader>bb", MiniPick.builtin.buffers, "Buffers")
keymap("n", "<leader>bn", "<cmd>bnext<CR>", "Next")
keymap("n", "<leader>bp", "<cmd>bprevious<CR>", "Previous")
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete")

-- Git stuff
keymap("n", "<leader>gg", "<cmd>term lazygit<CR>i", "Lazygit")
keymap("n", "<leader>gp", "<cmd>term gh pr create<CR>i", "Create PR")
keymap("n", "<leader>gW", "<cmd>term gh pr view<CR>i", "View PR (Terminal)")
keymap("n", "<leader>gw", "<cmd>!gh pr view --web<CR>", "View PR (Browser)")
keymap("n", "<leader>gd", "<cmd>term gh dash<CR>i", "GH dash")

-- Debugger
local dap = require("dap")
keymap("n", "<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
keymap("n", "<leader>dc", dap.continue, "Continue")
keymap("n", "<leader>di", dap.step_into, "Step Into")
keymap("n", "<leader>do", dap.step_over, "Step Over")
keymap("n", "<leader>dO", dap.step_out, "Step Out")
keymap("n", "<leader>dt", "<cmd>DapViewToggle<CR>", "Toggle View")

-- Testing
keymap("n", "<leader>tn", "<cmd>TestNearest<CR>", "Nearest")
keymap("n", "<leader>tf", "<cmd>TestFile<CR>", "File")
keymap("n", "<leader>ts", "<cmd>TestSuite<CR>", "Suite")
keymap("n", "<leader>tl", "<cmd>TestLast<CR>", "Last")
keymap("n", "<leader>tg", "<cmd>TestVisit<CR>", "Go To Last")

vim.lsp.enable({ "lua_ls", "nixd", "gopls", "tsserver", "sqls", "terraformls" })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			hint = {
				enable = true, -- necessary
			},
		},
	},
})

vim.lsp.config("gopls", {
	settings = {
		gopls = {
			hints = {
				rangeVariableTypes = true,
				parameterNames = true,
				constantValues = true,
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				functionTypeParameters = true,
			},
		},
	},
})

vim.lsp.config("tsserver", {
	settings = {
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
		javascript = {
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
	},
})
vim.cmd.colorscheme("catppuccin")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = function()
		vim.cmd("TSEnable highlight")
	end,
})
