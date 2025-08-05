local function status_line()
	local mode = "%-5{%v:lua.string.upper(v:lua.vim.fn.mode())%}"
	local file_name = "%-.16t"
	local buf_nr = "[%n]"
	local modified = " %-m"
	local file_type = " %y"
	local right_align = "%="
	local line_no = "%10([%l/%L%)]"
	local pct_thru_file = "%5p%%"

	return string.format(
		"%s%s%s%s%s%s%s%s",
		mode,
		file_name,
		buf_nr,
		modified,
		file_type,
		right_align,
		line_no,
		pct_thru_file
	)
end

local function install_deps()
	local github_url = "https://github.com/"

	vim.pack.add({
		{
			src = github_url .. "nvim-treesitter/nvim-treesitter",
			version = "master"
		},
		{ src = github_url .. "neovim/nvim-lspconfig" },
		{
			src = github_url .. "catppuccin/nvim",
			name = "catppuccin"
		},
		{ src = github_url .. "christoomey/vim-tmux-navigator" },
		{ src = github_url .. "folke/which-key.nvim" },
		{ src = github_url .. "HiPhish/rainbow-delimiters.nvim" },
		{
			src = github_url .. "echasnovski/mini.nvim",
			version = "main"
		},
		{ src = github_url .. "mfussenegger/nvim-dap" },
		{ src = github_url .. "leoluz/nvim-dap-go" },
		{ src = github_url .. "igorlfs/nvim-dap-view" },
		{ src = github_url .. "theHamsta/nvim-dap-virtual-text" },
		{ src = github_url .. "vim-test/vim-test" }
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
vim.opt.wrap = true
vim.opt.tabstop = 2
vim.opt.swapfile = false
vim.opt.winborder = "solid"
vim.opt.laststatus = 3
vim.opt.statusline = status_line()

vim.o.clipboard = "unnamedplus"

install_deps()

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			local chars = {}
			for i = 48, 122 do
				table.insert(chars, string.char(i))
			end
			client.server_capabilities.completionProvider.triggerCharacters = chars

			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
-- vim.cmd("set completeopt+=menuone,noselect,popup")
vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect", "popup", "preview" }

vim.api.nvim_set_keymap("i", "<C-space>", "vim.lsp.completion.trigger()",
	{ noremap = true, silent = true, expr = true, desc = "Trigger LSP Completion" })
vim.api.nvim_set_keymap("i", "<C-n>", "pumvisible() ? \"<C-n>\":\"<C-n>\"",
	{ noremap = true, silent = true, expr = true, desc = "Next completion item" })
vim.api.nvim_set_keymap("i", "<C-p>", "pumvisible() ? \"<C-p>\":\"<C-p>\"",
	{ noremap = true, silent = true, expr = true, desc = "Previous completion item" })
vim.api.nvim_set_keymap("i", "<CR>", "pumvisible() ? \"<C-y>\":\"<CR>\"",
	{ noremap = true, silent = true, expr = true, desc = "Accept completion or new line" })
vim.api.nvim_set_keymap("i", "<Tab>", "pumvisible() ?\"<C-n>\":\"<Tab>\"",
	{ noremap = true, silent = true, expr = true, desc = "Next completion item or tab" })
vim.api.nvim_set_keymap("i", "<S-Tab>", "pumvisible() ? \"<C-p>\":\"<S-Tab>\"",
	{ noremap = true, silent = true, expr = true, desc = "Previous completion item or shift-tab" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true)
		end
		-- whatever other lsp config you want
	end
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {},
	highlight = { enabled = true }
})

vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Enable Treesitter highlight on startup",
	group = vim.api.nvim_create_augroup("treesitter-highlight-on-startup", { clear = true }),
	callback = function()
		vim.cmd("TSEnable highlight")
	end,
})

require("mini.comment").setup()
require("mini.files").setup()
require("mini.pick").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.icons").setup()
require("mini.indentscope").setup()
require("mini.move").setup()
require("mini.notify").setup()
require("which-key").setup({
	preset = "helix",
	delay = 0,
	show_help = false,
	show_keys = true,
	icons = {
		mappings = false
	},
	win = {
		border = "none",
	},
	spec = {
		{ "<leader>b", group = "Buffers", mode = "n" },
		{ "<leader>g", group = "Git",     mode = "n" },
		{ "<leader>d", group = "Debug",   mode = "n" },
		{ "<leader>t", group = "Testing", mode = "n" },
	}
})

require("dap-go").setup()
require("nvim-dap-virtual-text").setup()
vim.cmd("let test#strategy = \"neovim_sticky\"")

vim.keymap.set("n", "<leader>\\", "<cmd>vsplit<CR>", { desc = "Vertical split", silent = true })
vim.keymap.set("n", "<leader><leader>", MiniPick.builtin.files, { desc = "Files", silent = true })
vim.keymap.set("n", "<leader>e", MiniFiles.open, { desc = "Explorer", silent = true })
vim.keymap.set("n", "<leader>/", MiniPick.builtin.grep_live, { desc = "Live grep", silent = true })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format", silent = true })
vim.keymap.set("n", "<leader>x", vim.diagnostic.setqflist, { desc = "Diagnostics", silent = true })

-- Navigation
vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<CR>")


-- Buffers
vim.keymap.set("n", "<leader>bb", MiniPick.builtin.buffers, { desc = "Buffers", silent = true })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next", silent = true })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous", silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete", silent = true })

-- Git stuff
vim.keymap.set("n", "<leader>gg", "<cmd>term lazygit<CR>i", { desc = "Lazygit", silent = true })
vim.keymap.set("n", "<leader>gp", "<cmd>term gh pr create<CR>i", { desc = "Create PR", silent = true })
vim.keymap.set("n", "<leader>gW", "<cmd>term gh pr view<CR>i", { desc = "View PR (Terminal)", silent = true })
vim.keymap.set("n", "<leader>gw", "<cmd>!gh pr view --web<CR>", { desc = "View PR (Browser)", silent = true })
vim.keymap.set("n", "<leader>gd", "<cmd>term gh dash<CR>i", { desc = "GH dash", silent = true })

-- Debugger
local dap = require("dap")
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint", silent = true })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue", silent = true })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into", silent = true })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over", silent = true })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step Out", silent = true })
vim.keymap.set("n", "<leader>dt", "<cmd>DapViewToggle<CR>", { desc = "Toggle View", silent = true })

-- Testing
vim.keymap.set("n", "<leader>tn", "<cmd>TestNearest<CR>", { desc = "Nearest", silent = true })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<CR>", { desc = "File", silent = true })
vim.keymap.set("n", "<leader>ts", "<cmd>TestSuite<CR>", { desc = "Suite", silent = true })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<CR>", { desc = "Last", silent = true })
vim.keymap.set("n", "<leader>tg", "<cmd>TestVisit<CR>", { desc = "Go To Last", silent = true })

vim.lsp.enable({ "lua_ls", "nixd", "gopls", "tsserver" })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true), -- hack to remove vim.* warnings
			},
			hint = {
				enable = true, -- necessary
			},
		}
	}
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
	}
})
vim.cmd.colorscheme("catppuccin")

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " "
		},
	}
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
