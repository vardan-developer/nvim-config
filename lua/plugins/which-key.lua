return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		spec = {
			-- Group names shown in the popup for existing keymap prefixes
			{ "<leader>f", group = "find / format" },
			{ "<leader>h", group = "git hunk" },
			{ "<leader>l", group = "lazy" },
		},
	},
}
