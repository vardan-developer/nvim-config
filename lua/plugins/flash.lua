return {
	"folke/flash.nvim",
	opts = {
		modes = {
			-- Enhanced f/t would also remap ; and , which are custom-mapped
			-- in keymaps.lua (; = command mode), so keep it off.
			char = { enabled = false },
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
