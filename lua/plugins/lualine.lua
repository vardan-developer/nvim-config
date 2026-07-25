return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- for file-type icons
	event = "VeryLazy", -- not needed instantly, so defer it
	opts = function()
		-- cond helper: hide a component when the window is narrower than `w`
		local function min_width(w)
			return function()
				return vim.fn.winwidth(0) > w
			end
		end

		-- 󰛢 2/5 when the current file is harpooned, empty otherwise
		local function harpoon_slot()
			local ok, harpoon = pcall(require, "harpoon")
			if not ok then
				return ""
			end
			local items = harpoon:list().items
			local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
			for i, item in ipairs(items) do
				if item.value == current then
					return "󰛢 " .. i .. "/" .. #items
				end
			end
			return ""
		end

		-- line number of the first trailing whitespace, empty when clean
		local function trailing_whitespace()
			local line = vim.fn.search([[\s\+$]], "nwc")
			return line ~= 0 and "tw:" .. line or ""
		end

		-- ● rec @q while a macro is recording, empty otherwise
		local function macro_recording()
			local reg = vim.fn.reg_recording()
			return reg ~= "" and "● rec @" .. reg or ""
		end
		-- statusline only refreshes on its timer; force it so the indicator
		-- appears/disappears the moment recording starts or stops
		vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
			callback = function()
				vim.schedule(function()
					require("lualine").refresh()
				end)
			end,
		})

		-- line number of the first mixed tab/space indentation, empty when clean
		local function mixed_indent()
			local space_indent = vim.fn.search([[\v^ +]], "nwc")
			local tab_indent = vim.fn.search([[\v^\t+]], "nwc")
			if space_indent > 0 and tab_indent > 0 then
				return "mi:" .. math.max(space_indent, tab_indent)
			end
			local mixed_same = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")
			return mixed_same > 0 and "mi:" .. mixed_same or ""
		end

		return {
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
				lualine_b = {
					{ "branch", cond = min_width(70) },
					{ "diff", cond = min_width(70) },
					"diagnostics",
				},
				-- filename with path relative to cwd, [+] when modified
				lualine_c = { { "filename", path = 1 }, harpoon_slot },
				lualine_x = {
					{ macro_recording, color = "DiagnosticError" },
					-- code-hygiene warnings, shown only when something is off
					{ trailing_whitespace, color = "DiagnosticError" },
					{ mixed_indent, color = "DiagnosticError" },
					-- attached LSP server(s); drops the utf-8/unix noise
					{
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
						cond = min_width(100),
					},
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		}
	end,
	enabled = true,
}
