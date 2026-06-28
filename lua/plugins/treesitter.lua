return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- the rewrite; required for nvim 0.12
	lazy = false,
	build = ":TSUpdate", -- keep parsers up to date on plugin update
	config = function()
		-- The parsers (languages) you want installed
		local parsers = {
			"lua",
			"vim",
			"vimdoc",
			"query", -- for editing your own nvim config
			"bash",
			"markdown",
			"markdown_inline",
			"python",
			"json",
			"yaml",
			"rust",
			"cpp",
		}
		require("nvim-treesitter").install(parsers)

		-- Highlighting is NOT automatic on the main branch — you turn it on
		-- yourself. This enables it whenever you open a file.
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start) -- pcall = ignore filetypes with no parser
			end,
		})
	end,
}
