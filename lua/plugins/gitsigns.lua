return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			-- Jump between hunks (blocks of uncommitted changes)
			map("n", "]h", function()
				gs.nav_hunk("next")
			end, "Next git hunk")
			map("n", "[h", function()
				gs.nav_hunk("prev")
			end, "Prev git hunk")

			-- Act on the hunk under the cursor
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk diff")
			map("n", "<leader>hs", gs.stage_hunk, "Stage hunk (again to unstage)")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk (revert to committed)")
			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Blame current line")
		end,
	},
}
