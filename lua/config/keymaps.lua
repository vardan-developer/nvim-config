local map = vim.keymap.set

vim.g.mapleader = " " -- space as leader
vim.g.maplocalleader = " " -- localleader (used by some plugins)

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

vim.opt.clipboard = 'unnamedplus'

-- This is just for the NFS folders saving because otherwise it causes issues in saving xattrs
vim.cmd([[cnoreabbrev <expr> w  (getcmdtype()==':' && getcmdline()==#'w')  ? 'silent! write'              : 'w']])
vim.cmd([[cnoreabbrev <expr> wq (getcmdtype()==':' && getcmdline()==#'wq') ? 'silent! write <bar> quit'   : 'wq']])
vim.cmd([[cnoreabbrev <expr> x  (getcmdtype()==':' && getcmdline()==#'x')  ? 'silent! write <bar> quit'   : 'x']])

map("n", "<M-q>", "<cmd>q<cr>", { desc = "use meta+q to exit panes" })

-- Use ; as the command key in normal and visual mode
map({ "n", "x" }, ";", ":", { desc = "Command mode" })
map({ "n", "x" }, "'", ";", { desc = "Repeat find" })

-- Clear search highlight after a search, by pressing Esc
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Move between split windows with Ctrl + h/j/k/l (no Ctrl-w prefix needed)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Move selected lines up/down in visual mode (J/K), keeping selection
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping half-pages
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down + center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up + center" })

-- Move back to last position of cursor using =,-
map("n", "=", "<C-i>", { desc = "Jump to the next position you jumped from" })
map("n", "-", "<C-o>", { desc = "Jump to the previous location you jumped from" })

-- Auto recenter after n and N
map("n", "n", "nzz", { desc = "Auto recenter after n" })
map("n", "N", "Nzz", { desc = "Auto recenter after N" })

-- Open the file explorer
map("n", "<Leader>e", "<cmd>Ex<cr>", { desc = "Open Netrw using leader pe" })

-- Remap formatting file keybind to leader + fm using conform
map({ "n", "v" }, "<leader>fm", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file/selection" })

-- Copy the word with yw instead of yiw
map({ "n" }, "yw", "yiw", { desc = "yank the inner word" })
