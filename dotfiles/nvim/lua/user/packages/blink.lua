local M = {}

function M.setup()
	require("blink.cmp").setup({
		keymap = {
			preset = nil,
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},
		completion = {
			documentation = { auto_show = true },
			list = { selection = { preselect = false } },
			trigger = {
				show_in_snippet = false,
			},
		},
	})
end

return M
