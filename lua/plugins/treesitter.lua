return {
	{
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
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			max_lines = 3, -- max context lines shown at the top
			multiline_threshold = 1,
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()

			-- MOVE between text objects
			local move = require("nvim-treesitter-textobjects.move")
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "]F", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "[F", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Prev function end" })
		end,
	},
}
