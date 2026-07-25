return {
	"akinsho/git-conflict.nvim",
	version = "*", -- latest stable release
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("git-conflict").setup({
			default_mappings = true, -- co / ct / cb / c0 / ]x / [x in conflicted buffers
			-- The plugin's own disable_diagnostics calls vim.diagnostic.disable(),
			-- which nvim 0.12 removed, and upstream (last commit Nov 2024) has no
			-- fix — so it stays off and the autocmds below replicate it.
			disable_diagnostics = false,
		})

		-- Pause diagnostics while a buffer has conflicts, resume when resolved
		vim.api.nvim_create_autocmd("User", {
			pattern = "GitConflictDetected",
			callback = function()
				vim.diagnostic.enable(false, { bufnr = vim.api.nvim_get_current_buf() })
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			pattern = "GitConflictResolved",
			callback = function()
				vim.diagnostic.enable(true, { bufnr = vim.api.nvim_get_current_buf() })
			end,
		})
	end,
}
