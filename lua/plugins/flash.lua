return {
	"folke/flash.nvim",
	-- Load at startup (not just on S) so the f/t enhancement is active
	-- from the first keypress.
	event = "VeryLazy",
	opts = {
		modes = {
			char = {
				enabled = true,
				-- Only take over f/F/t/T; leave ; and , alone since ; is
				-- command mode and ' is repeat-find (see keymaps.lua).
				keys = { "f", "F", "t", "T" },
				-- clever-f style repeat: after fx, press f again for the
				-- next match and F for the previous one (t/T likewise).
				char_actions = function(motion)
					return {
						[motion:lower()] = "next",
						[motion:upper()] = "prev",
					}
				end,
			},
		},
	},
	keys = {
		-- s is the mini.surround prefix (sa/sd/sr...) and <leader>s is
		-- harpoon, so jump lives on S (default S = synonym for cc).
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash jump",
		},
	},
}
