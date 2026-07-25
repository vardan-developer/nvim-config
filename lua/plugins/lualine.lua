return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- for file-type icons
	event = "VeryLazy", -- not needed instantly, so defer it
	opts = {
		options = {
			theme = "auto", -- colorschemes with lualine support (modus does) style it
			-- rounded "bubble" sections with thin dividers inside them
			section_separators = { left = "", right = "" },
			component_separators = { left = "│", right = "│" },
		},
		sections = {
			-- single-letter mode: N / I / V / ...
			lualine_a = {
				{
					"mode",
					fmt = function(s)
						return s:sub(1, 1)
					end,
				},
			},
			lualine_b = { "branch", "diff", "diagnostics" },
			-- filename with path relative to cwd, [+] when modified
			lualine_c = { { "filename", path = 1 } },
			-- attached LSP server + filetype (drops encoding/fileformat noise)
			lualine_x = {
				function()
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					if #clients == 0 then
						return ""
					end
					local names = {}
					for _, c in ipairs(clients) do
						table.insert(names, c.name)
					end
					return " " .. table.concat(names, ",")
				end,
				"filetype",
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	},
	enabled = true,
}
