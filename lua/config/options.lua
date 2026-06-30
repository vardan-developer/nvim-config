local opt = vim.opt

-- General
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- use the system clipboard
opt.swapfile = false -- no swap files (using auto-save.nvim)

-- UI / display
opt.termguicolors = true -- enable 24-bit colors (set this early)
opt.number = true -- absolute line numbers
opt.relativenumber = true -- relative line numbers
opt.cursorline = true -- highlight the current line
opt.wrap = true -- wrap long lines

-- Indentation
opt.autoindent = true
opt.expandtab = true -- tabs become spaces
opt.shiftwidth = 4 -- indent width
opt.tabstop = 4 -- a tab counts as 4 spaces

-- Search
opt.ignorecase = true -- case-insensitive...
opt.smartcase = true -- ...unless the query has uppercase

-- Splits
opt.splitright = true -- vertical splits open to the right
opt.splitbelow = true -- horizontal splits open below

-- Folding & behavior
opt.foldlevelstart = 99 -- start with everything unfolded
opt.formatoptions:append("cro") -- continue comments on new lines (C-u to remove)
opt.sessionoptions:remove("options") -- don't persist keymaps/local options

-- Always have buffer on top and bottom of screen 
opt.scrolloff = 8
