return {
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000, -- load before all other plugins so nothing flashes unstyled
		config = function()
			-- oxocarbon has no setup(); it reads 'background' for its
			-- dark (near-black) or light variant.
			vim.opt.background = "dark"
			vim.cmd.colorscheme("oxocarbon")
		end,
	},
	{
		-- Kept installed but not applied — switch back any time with
		-- :colorscheme kanagawa (or kanagawa-dragon / kanagawa-lotus).
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				compile = false, -- leave off for now (no :KanagawaCompile chore)
				theme = "wave", -- try "dragon" or "lotus" too
			})
		end,
	},
}
