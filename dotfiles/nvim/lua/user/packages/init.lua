local M = {}

local github_url = "https://github.com/"

M.mini = require("user.packages.mini")

function M.install_deps()
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

function M.setup()
	M.install_deps()
	M.mini.setup()

	require("which-key").setup({
		preset = "classic",
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

	conform.setup({
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "gofmt", "golines", "goimport" },
			nix = { "alejandra" },
		},
	})


end

return M
