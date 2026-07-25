# Neovim Config — New Machine Setup

Cloning the config repo is **not enough**. The config assumes a set of system tools
exist on the machine, and on managed/corporate machines a few environment quirks
(NFS home directories, node version managers, restricted permissions) need handling.

This document lists everything required *outside* the repo to get plugins, Treesitter,
LSP, and formatters working.

Target: **Neovim 0.12+** (uses the native `vim.lsp` API and the nvim-treesitter
**main** branch, both of which need a recent Neovim).

---

## 1. Quick checklist

- [ ] Neovim 0.12+
- [ ] `git`
- [ ] A C/C++ compiler (`gcc` or `clang`) + `make`
- [ ] Download/extract utilities: `curl`, `unzip`, `tar`, `gzip`
- [ ] Node.js + `npm` available on the PATH **Neovim sees** (see Section 5 — nvm caveat)
- [ ] `tree-sitter` CLI on PATH (for Treesitter parser generation)
- [ ] Python 3 available (for Python tooling that needs it)
- [ ] A **Nerd Font** installed and selected in the terminal
- [ ] A terminal with **truecolor** support (+ tmux passthrough if using tmux)
- [ ] **If home is on NFS:** Mason's install dir relocated to local disk (Section 4) — **critical**

---

## 2. Why each dependency is needed

| Dependency | Needed by | Breaks without it |
|---|---|---|
| `git` | lazy.nvim bootstrap + plugin clones | No plugins install |
| C compiler + `make` | Treesitter parsers; clangd | Parsers fail to build; weak C/C++ LSP |
| `tree-sitter` CLI | nvim-treesitter **main** branch | Parser install fails (generate step) |
| `curl`, `unzip`, `tar`, `gzip` | Mason downloads | Mason installs fail at download/extract |
| Node.js + `npm` | npm-based LSP servers (e.g. bash) | Those servers fail to install |
| Python 3 | Python-based tooling | Python tooling fails |
| Nerd Font | lualine / web-devicons | Icons render as boxes |
| Truecolor terminal | colorscheme | Colors look wrong |
| Mason on local disk | Mason (if home is NFS) | "link target does not exist" install failures |

---

## 3. Base install (where you have permissions)

### Debian / Ubuntu
```bash
sudo apt update
sudo apt install -y git build-essential make curl unzip tar gzip python3 nodejs npm
# tree-sitter CLI (pick one)
npm install -g tree-sitter-cli
# or, with Rust: cargo install tree-sitter-cli
```

### Fedora / RHEL
```bash
sudo dnf install -y git make gcc gcc-c++ curl unzip tar gzip python3 nodejs npm
npm install -g tree-sitter-cli
```

### macOS (Homebrew)
```bash
xcode-select --install
brew install node python tree-sitter
```

> **No sudo on this machine?** See Section 7 — most of this can be obtained through a
> module system, conda, or by asking IT, and some LSP tools are accepted as already
> present rather than installed by Mason.

---

## 4. CRITICAL: NFS home directories

Many corporate machines mount the home directory over **NFS**. Mason installs to
`~/.local/share/nvim/mason/` by default — i.e. onto NFS — and NFS breaks the symlink
step Mason uses, producing:

```
Link target ".../mason/packages/<tool>/<tool>" does not exist
```

even though the download and extraction succeeded.

**Check whether home is NFS:**
```bash
findmnt -T "$HOME"      # look for FSTYPE = nfs / nfs4
```

**If it is NFS, relocate Mason to local disk.** Find a local path:
```bash
findmnt -T /var/tmp     # FSTYPE should be ext4/xfs/etc. (NOT nfs)
```

Then set Mason's install root in the config (mason.nvim spec):
```lua
{
  "mason-org/mason.nvim",
  opts = {
    install_root_dir = "/var/tmp/mason-<username>",  -- a LOCAL, non-NFS path
    max_concurrent_installers = 1,                   -- avoid bulk-install flakiness
  },
}
```

Notes:
- Pick a path that is **local and persistent**. `/var/tmp` usually survives reboots; `/tmp`
  often does not.
- This path is **per-machine** — a different physical box re-downloads its own copies. Expected.
- `max_concurrent_installers = 1` makes installs run one at a time, which is far more
  reliable on constrained machines.

---

## 5. Node / npm on machines using `nvm`

If the machine uses **nvm** (Node Version Manager), `npm` is only on the PATH when nvm is
loaded by your interactive shell. Mason runs in Neovim's environment, which may **not**
have nvm loaded — so Mason reports:

```
Could not find executable "npm" in PATH
```

**Fixes (in order of robustness):**

1. **Set an nvm default** so a Node version is always active in new shells:
   ```bash
   nvm alias default node
   ```
   (Stops the "have to reinstall/select Node every session" problem.)

2. **Launch Neovim from a shell where `npm` works**, so nvim inherits that PATH.
   Verify inside nvim:
   ```
   :lua print(vim.fn.exepath("npm"))
   ```
   A path = good. Empty = nvim's PATH lacks npm.

3. **Most reliable:** ensure some `npm` is on the system PATH regardless of nvm (e.g. a
   system Node install), so Mason always finds it.

If you don't need npm-based servers (e.g. bash-language-server), simply don't list them
in `ensure_installed` and npm is irrelevant.

---

## 6. LSP servers & formatters

Two categories:

### A. Installed by Mason (no special handling)
Listed in the config's `ensure_installed`; Mason installs and auto-enables them:
- `lua_ls` — Lua
- `clangd` — C/C++
- `stylua` — Lua formatter
- `clang-format` — C/C++ formatter

These require their underlying toolchain to be present where they run (clangd needs a
C/C++ toolchain; for large projects, a `compile_commands.json` at the project root).

### B. Provided externally, NOT installed by Mason
Some tools are **accepted as already available on the system** rather than installed by
Mason — they must be present on the PATH Neovim sees, and the config enables them with
`vim.lsp.enable(...)` instead of listing them in Mason's `ensure_installed`:
- `ty` — Python language server
- `ruff` — Python linter/formatter

Requirements for category B:
- The `ty` and `ruff` executables must be on the PATH Neovim sees.
- They are **not** in Mason's `ensure_installed` (so Mason never tries to install them).
- The config calls `vim.lsp.enable("ty")` and `vim.lsp.enable("ruff")`.

Verify Neovim can see them:
```
:lua print(vim.fn.exepath("ty"))
:lua print(vim.fn.exepath("ruff"))
```
A path = good. Empty = the PATH Neovim launched with does not include their location;
ensure that location (e.g. `~/.local/bin`) is on the PATH **before** Neovim starts.

---

## 7. No-sudo machines

If you lack `sudo`, you cannot use `apt`/`dnf`. Options:

- **Environment modules:** `module avail` / `module avail python node` — many firms
  provide compilers, Python, and Node this way.
- **conda / mamba:** create an environment in your home with the tools you need
  (Python, Node, etc.) — no sudo required.
- **Ask IT** to install system packages you can't (e.g. compiler, Python venv support),
  or to tell you the sanctioned way to get developer tooling.
- **Category-B tools (ty, ruff):** these are accepted as externally provided, so they can
  live in your home on PATH without sudo and without Mason.

---

## 8. Terminal-side setup (not in the repo)

- **Nerd Font:** install one and select it in the terminal profile, or icons render as boxes.
- **Truecolor:** use a modern terminal (kitty, WezTerm, Alacritty, iTerm2, Ghostty).
  macOS Terminal.app supports neither truecolor nor OSC 52.
- **tmux** (if used), in `~/.tmux.conf`:
  ```
  set -g set-clipboard on
  set -g default-terminal "tmux-256color"
  set -ga terminal-overrides ",*256col*:Tc"
  ```
  Reload: `tmux source-file ~/.tmux.conf`.

---

## 9. First launch & verification

```bash
nvim
```
lazy.nvim bootstraps and installs plugins; Treesitter compiles parsers; Mason installs
the category-A tools.

Verify inside Neovim:
```
:Lazy                          # plugins installed, no errors
:Mason                         # category-A tools installed
:checkhealth mason             # Mason can see its backends (curl, unzip, npm, python...)
:checkhealth vim.lsp           # which LSP servers attached
:checkhealth nvim-treesitter   # CLI + compiler found, parsers installed
:ConformInfo                   # formatters detected for current buffer
```

Practical tests (always inside a real project — a folder with `.git/` or a marker):
- Lua file -> `lua_ls` attaches; `vim.` gives rich completions.
- C/C++ file -> `clangd` attaches.
- Python file -> `ty` + `ruff` attach (category B; must be on PATH).
- `<leader>f` -> formats the file.

---

## 10. Troubleshooting map

| Symptom | Likely cause | Fix |
|---|---|---|
| `Link target ... does not exist` | Mason installing on NFS home | Relocate `install_root_dir` to local disk (Section 4) |
| Bulk install fails, single installs work | Too many parallel installers | `max_concurrent_installers = 1` |
| `Could not find executable "npm"` | nvm not loaded in nvim's PATH | Section 5 |
| `python3 failed with exit code 1` | Python tool can't install via Mason | Use category-B (external) tools; see Sections 6-7 |
| LSP server not attaching | Not on PATH, or no project root | Check `:lua print(vim.fn.exepath("<tool>"))`; open inside a project |
| Parsers won't build | Missing tree-sitter CLI or C compiler | Section 3; `:checkhealth nvim-treesitter` |
| Icons are boxes | No Nerd Font | Section 8 |
| Colors look wrong | No truecolor / tmux passthrough | Section 8 |

**Always start debugging with the matching `:checkhealth` command** — it usually names
the cause. For install errors, `:MasonLog` shows the real error behind the generic
"exit code 1".

---

## Summary

The repo provides the **configuration**. Each machine still needs: a compiler, git,
download/extract utilities, the tree-sitter CLI, Node/npm (on a PATH Neovim sees),
Python 3, a Nerd Font, and a truecolor terminal. On NFS-home machines, Mason **must**
be relocated to local disk. Category-A tools install via Mason; category-B tools
(`ty`, `ruff`) are accepted as externally provided and enabled directly. Launch once,
then verify with the `:checkhealth` commands.
