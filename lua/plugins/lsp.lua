return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT", -- Neovim uses LuaJIT, not standard Lua
					},
					diagnostics = {
						globals = { "vim" }, -- (still useful) recognize `vim` as global
					},
					workspace = {
						-- THIS is what gives you vim.* completions:
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = { enable = false },
				},
			},
		})
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local buf = args.buf
				local map = function(keys, fn, desc)
					vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
				end
				map("gd", vim.lsp.buf.definition, "Go to definition")
				map("gr", vim.lsp.buf.references, "Find references")
				map("K", vim.lsp.buf.hover, "Hover docs")
				map("<leader>rn", vim.lsp.buf.rename, "Rename")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action")
			end,
		})
	end,
}
