return {
	"saghen/blink.cmp",
	version = "*", -- track the latest stable release
	event = "InsertEnter", -- lazy-load: only when you start typing
	opts = {
		keymap = {
			preset = "super-tab",
			["<Esc>"] = { "cancel", "fallback" },
		},
		sources = {
			default = { "lsp", "path", "buffer", "snippets" },
		},
	},
}
