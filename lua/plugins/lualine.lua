return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- for file-type icons
	event = "VeryLazy", -- not needed instantly, so defer it
	opts = {
		options = {
			theme = "auto", -- follow whatever colorscheme is active
		},
	},
	enabled = true,
}
