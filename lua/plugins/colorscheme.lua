return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("kanagawa").setup({
			compile = false, -- leave off for now (no :KanagawaCompile chore)
			theme = "wave", -- try "dragon" or "lotus" too
		})
		vim.cmd.colorscheme("kanagawa")
	end,
	enabled = true,
}
