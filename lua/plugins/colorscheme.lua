return {
	{
		"miikanissi/modus-themes.nvim",
		lazy = false,
		priority = 1000, -- load before all other plugins so nothing flashes unstyled
		config = function()
			require("modus-themes").setup({
				-- "auto" picks by 'background': dark -> modus_vivendi,
				-- light -> modus_operandi
				style = "auto",
				variants = {
					modus_operandi = "default",
					modus_vivendi = "default", -- try "tinted" for warmer, softer bg
				},
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
				},
			})
			vim.opt.background = "dark"
			vim.cmd.colorscheme("modus")
		end,
	},
	{
		-- Kept installed but not applied — try live with :colorscheme oxocarbon
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
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
