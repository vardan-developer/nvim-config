return {
	"stevearc/conform.nvim",
	event = "BufWritePre", -- load right before saving
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			-- c = { "clang-format" },
			-- cpp = { "clang-format" },
		},
	},
}
