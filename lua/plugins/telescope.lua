return {
	"nvim-telescope/telescope.nvim",
	branch = "master", -- 0.1.x is frozen; master supports the new treesitter APIs
	dependencies = {
		"nvim-lua/plenary.nvim", -- required utility library
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make", -- compiles a C sorter for speed (needs gcc + make)
		},
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({})
		pcall(telescope.load_extension, "fzf")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep in project" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Open buffers" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
		vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current file" })
		vim.keymap.set("n", "<leader>fa", function()
			-- Grep the word under the cursor across the project; start in
			-- normal mode so j/k browse results right away.
			builtin.grep_string({ initial_mode = "normal" })
		end, { desc = "Find word under cursor in project" })
		vim.keymap.set("n", "<leader>fi", function()
			-- Same as <leader>fa but scoped to the current buffer only.
			builtin.current_buffer_fuzzy_find({
				default_text = vim.fn.expand("<cword>"),
				initial_mode = "normal",
			})
		end, { desc = "Find word under cursor in current file" })
	end,
}
