# Neovim Config

Lua config for **Neovim 0.12+**. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim),
LSP servers and tools by [Mason](https://github.com/mason-org/mason.nvim), syntax by
nvim-treesitter (**main** branch), and formatting by conform.nvim. Everything bootstraps
itself on first launch — clone, install the system dependencies below, open `nvim`.

## Structure

```
init.lua                 # entry point — loads the three config modules
lua/config/
  options.lua            # editor options
  keymaps.lua            # leader = <space>, general keymaps, OSC 52 clipboard
  lazy.lua               # lazy.nvim bootstrap + plugin loader
lua/plugins/             # one file per plugin, auto-imported by lazy.nvim
  lsp.lua                # LSP server settings + LSP keymaps
  mason.lua              # which servers/tools get installed
  treesitter.lua         # parsers + highlighting
  formatting.lua         # conform.nvim (format on <leader>f)
  completions.lua, telescope.lua, neotree.lua, harpoon.lua,
  colorscheme.lua, lualine.lua, mini-ai.lua, mini-surround.lua, ...
lazy-lock.json           # pinned plugin versions
```

## How it works

- On first launch, `lua/config/lazy.lua` clones lazy.nvim if missing, then loads every
  spec in `lua/plugins/`.
- Mason auto-installs and enables the LSP servers `lua_ls`, `clangd`, `ty`, `bashls`,
  plus the tools `stylua` and `ruff`.
- Treesitter installs its parsers and turns on highlighting per filetype.
- conform.nvim formats with `stylua` (Lua) and `ruff` (Python).

## What to install

| Tool | Why |
|---|---|
| Neovim 0.12+ | native `vim.lsp` API + treesitter main branch need it |
| `git` | lazy.nvim bootstrap and plugin clones |
| C compiler (`gcc`/`clang`) + `make` | building treesitter parsers |
| `curl`, `unzip`, `tar`, `gzip` | Mason package downloads |
| `tree-sitter` CLI | parser generation on the treesitter main branch |
| Node.js + `npm` | npm-based LSP servers (e.g. `bashls`) |
| Python 3 | Python tooling |
| A Nerd Font + truecolor terminal | icons and colors render correctly |

## Install

### Debian / Ubuntu
```bash
sudo apt update
sudo apt install -y git build-essential curl unzip tar gzip python3 nodejs npm
npm install -g tree-sitter-cli
```

### Fedora / RHEL
```bash
sudo dnf install -y git make gcc gcc-c++ curl unzip tar gzip python3 nodejs npm
npm install -g tree-sitter-cli
```

### macOS (Homebrew)
```bash
xcode-select --install
brew install node python
cargo install tree-sitter-cli
```

The `tree-sitter` CLI comes from cargo, not brew — the brew formula is kept
unlinked as a library dependency of neovim itself, so its binary never lands
on PATH.

### Then get the config

The **recommended way** is through the main
[configs](https://github.com/vardan-developer/configs) repo, which always pins the most
stable version of each config. It is designed to live at `~/.config`, so the nvim
config lands at `~/.config/nvim` automatically:

```bash
git clone https://github.com/vardan-developer/configs.git ~/.config
cd ~/.config
git submodule update --init nvim
nvim
```

If `~/.config` already exists, clone the configs repo somewhere else, init the `nvim`
submodule, and copy the `nvim` folder to `~/.config/nvim`.

**Direct clone** also works — you just get the latest `main` instead of the stable
version pinned by the configs repo:

```bash
git clone https://github.com/vardan-developer/nvim-config.git ~/.config/nvim
nvim
```

First launch takes a minute: lazy.nvim installs plugins, treesitter compiles parsers,
Mason installs the LSP servers. Restart Neovim once it settles.

### Verify
```
:Lazy                          # plugins installed, no errors
:Mason                         # servers/tools installed
:checkhealth mason             # Mason can see curl, unzip, npm, python...
:checkhealth vim.lsp           # which LSP servers attached
:checkhealth nvim-treesitter   # compiler + CLI found, parsers installed
```

## Nuances

- **NFS home directory** (common on corporate machines): Mason installs to
  `~/.local/share/nvim/mason/` by default, and its symlink step fails on NFS with
  `Link target ... does not exist`. Fix: point Mason at local disk in the mason spec:

  ```lua
  { "mason-org/mason.nvim", opts = { install_root_dir = "/var/tmp/mason-<user>" } }
  ```

- **nvm users:** Mason needs `npm` on the PATH Neovim sees. Run `nvm alias default node`
  so a Node version is always active, and launch Neovim from a shell where `npm` works.
- **Clipboard is OSC 52** — copy/paste goes through the terminal escape sequence, so the
  terminal must support OSC 52 (most modern ones do; macOS Terminal.app does not).
- **tmux:** add truecolor + clipboard passthrough to `~/.tmux.conf`:

  ```
  set -g set-clipboard on
  set -g default-terminal "tmux-256color"
  set -ga terminal-overrides ",*256col*:Tc"
  ```

- **Stuck?** Start with the matching `:checkhealth` command — it usually names the
  cause. For Mason install errors, `:MasonLog` has the real error.

## Troubleshooting

### Syntax highlighting silently broken (e.g. C++ files look almost uncolored)

Happens on machines that ever ran the nvim-treesitter **master** branch before this
config switched to **main**. Symptoms: lua/markdown files highlight fine, but cpp,
python, rust etc. are nearly bare — while LSP still works.

Cause: the old master branch compiled parsers *into the plugin directory itself*
(`parser/`, `parser-info/`). Those are untracked files, so they survive the branch
switch — but master's query files were tracked, so they get deleted by it. The main
branch installer then sees the leftover parsers, assumes everything is installed, and
never installs its own parsers + highlight queries into `~/.local/share/nvim/site`.
Result: treesitter attaches with a parser but no queries (which also disables the old
regex highlighting). Lua/markdown still work only because Neovim core ships queries
for them.

Fix — delete the stale leftovers and reinstall:

```bash
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter/parser \
       ~/.local/share/nvim/lazy/nvim-treesitter/parser-info
```

then reopen Neovim (the config auto-installs parsers on startup), or run the install
explicitly and wait for it:

```bash
nvim --headless "+lua require('nvim-treesitter').install({'lua','vim','vimdoc','query','bash','markdown','markdown_inline','python','json','yaml','rust','cpp','c'}):wait(300000)" +qa
```

Verify with `:checkhealth nvim-treesitter` and by confirming
`~/.local/share/nvim/site/queries/cpp/highlights.scm` exists.

Related requirements that fail with clearer errors: Neovim **0.12+** (older gives
`attempt to index field 'list'` during install) and the `tree-sitter` CLI on PATH
(missing gives `ENOENT ... 'tree-sitter'`).
