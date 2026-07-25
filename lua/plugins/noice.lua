return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" }, -- already installed (neo-tree dep)
	opts = {
		lsp = {
			-- render LSP hover/signature docs through noice's markdown
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		presets = {
			bottom_search = true, -- classic bottom-line / search instead of a popup
			command_palette = true, -- : cmdline as a centered popup with completions above
			long_message_to_split = true, -- long output goes to a split, no hit-enter walls
		},
	},
}
