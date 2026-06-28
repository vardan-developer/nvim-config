return {
	{
		-- For installing LSP and configuring them with nvim-lspconfig
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = { "lua_ls", "clangd", "ty", "bashls" },
			automatic_enable = true,
		},
	},
	{
		-- For installing all tools by mason
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = { ensure_installed = { "stylua", "ruff" } },
	},
}
