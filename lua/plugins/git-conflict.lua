return {
	"akinsho/git-conflict.nvim",
	version = "*", -- latest stable release
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		default_mappings = true, -- co / ct / cb / c0 / ]x / [x in conflicted buffers
		disable_diagnostics = true, -- pause LSP diagnostics while a buffer has conflicts
	},
}
