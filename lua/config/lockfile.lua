-- Auto-commit lazy-lock.json after an explicit plugin update.
--
-- Plugins are pinned to the lockfile and only move when I run :Lazy update
-- myself, so every update deserves its own small commit instead of piling up
-- as an uncommitted diff. This repo is a submodule of ~/.config, so the bump
-- is also recorded in the parent (prefixed "nvim: ") when the parent is on the
-- same branch.
--
-- Guards, in order: nothing else may be modified, the lockfile must actually
-- have changed, we must be on (or able to reach) the `local` branch, and I get
-- a y/n prompt before anything is written.

local M = {}

local LOCKFILE = "lazy-lock.json"
local BRANCH = "local"

local function warn(msg)
	vim.notify("lazy-lock: " .. msg, vim.log.levels.WARN)
end

local function info(msg)
	vim.notify("lazy-lock: " .. msg, vim.log.levels.INFO)
end

-- Run git in `cwd`; returns exit code plus raw stdout/stderr. Output is left
-- untrimmed because porcelain status lines are column-significant.
local function git(cwd, args)
	local cmd = { "git", "-C", cwd }
	vim.list_extend(cmd, args)
	local res = vim.system(cmd, { text = true }):wait()
	return res.code, res.stdout or "", res.stderr or ""
end

-- git() for commands whose output is a single value (a ref, a path, a sha).
local function git1(cwd, args)
	local code, out, err = git(cwd, args)
	return code, vim.trim(out), vim.trim(err)
end

-- Tracked paths with staged or unstaged changes, excluding `ignore`.
-- Untracked files are deliberately not counted: a stray scratch file
-- shouldn't block a lockfile bump, it can never end up in the commit.
local function other_changes(cwd, ignore)
	local code, out = git(cwd, { "status", "--porcelain", "--untracked-files=no" })
	if code ~= 0 then
		return nil
	end
	local others = {}
	for line in out:gmatch("[^\r\n]+") do
		local path = line:sub(4)
		if path ~= ignore then
			table.insert(others, path)
		end
	end
	return others
end

-- True when `path` differs from HEAD (this is what keeps commits non-empty).
local function has_changes(cwd, path)
	local code = git(cwd, { "diff", "--quiet", "HEAD", "--", path })
	return code == 1
end

-- Make sure `cwd` is on BRANCH, creating or switching to it when that is safe.
-- Returns true on success, or false plus a reason to abort.
local function ensure_branch(cwd)
	local code, current = git1(cwd, { "branch", "--show-current" })
	if code ~= 0 then
		return false, "cannot read current branch"
	end
	if current == BRANCH then
		return true
	end
	if current == "" then
		return false, "detached HEAD, refusing to guess a branch"
	end

	local exists = git(cwd, { "rev-parse", "--verify", "--quiet", "refs/heads/" .. BRANCH }) == 0
	if exists then
		local _, head = git1(cwd, { "rev-parse", "HEAD" })
		local _, target = git1(cwd, { "rev-parse", BRANCH })
		if head ~= target then
			return false,
				("`%s` is at %s but %s is at %s — diverged, resolve by hand"):format(
					BRANCH,
					target:sub(1, 7),
					current,
					head:sub(1, 7)
				)
		end
		local sw, _, err = git1(cwd, { "switch", BRANCH })
		if sw ~= 0 then
			return false, ("cannot switch to `%s`: %s"):format(BRANCH, err)
		end
	else
		local sw, _, err = git1(cwd, { "switch", "-c", BRANCH })
		if sw ~= 0 then
			return false, ("cannot create `%s`: %s"):format(BRANCH, err)
		end
	end
	return true
end

-- The parent repo and this repo's path within it, when we are a submodule.
local function superproject(cwd)
	local code, parent = git1(cwd, { "rev-parse", "--show-superproject-working-tree" })
	if code ~= 0 or parent == "" then
		return nil
	end
	local _, root = git1(cwd, { "rev-parse", "--show-toplevel" })
	local rel = root:sub(#parent + 2)
	if rel == "" then
		return nil
	end
	return parent, rel
end

-- Decode a lockfile; nil when it is missing or not valid JSON.
local function decode(text)
	local ok, tbl = pcall(vim.json.decode, text)
	if not ok or type(tbl) ~= "table" then
		return nil
	end
	return tbl
end

-- The committed lockfile. An empty table (not nil) when the file is new in
-- this commit, so every plugin reads as an addition.
local function lock_at_head(cwd)
	local code, out = git(cwd, { "show", "HEAD:" .. LOCKFILE })
	if code ~= 0 then
		return {}
	end
	return decode(out)
end

-- The working-tree lockfile, which is what `git commit -- <path>` records.
local function lock_on_disk(cwd)
	local ok, lines = pcall(vim.fn.readfile, cwd .. "/" .. LOCKFILE)
	if not ok then
		return nil
	end
	return decode(table.concat(lines, "\n"))
end

local function short(sha)
	return (sha or "?"):sub(1, 7)
end

-- Sort the two lockfiles into added / removed / updated plugins.
local function diff_locks(old, new)
	local added, removed, updated = {}, {}, {}
	for name, spec in pairs(new) do
		local prev = old[name]
		if not prev then
			table.insert(added, { name = name, to = spec.commit })
		elseif prev.commit ~= spec.commit then
			table.insert(updated, { name = name, from = prev.commit, to = spec.commit })
		end
	end
	for name, spec in pairs(old) do
		if not new[name] then
			table.insert(removed, { name = name, from = spec.commit })
		end
	end
	local by_name = function(a, b)
		return a.name < b.name
	end
	table.sort(added, by_name)
	table.sort(removed, by_name)
	table.sort(updated, by_name)
	-- { imperative, past tense, entries } — both word forms are spelled out
	-- because deriving one from the other needs per-verb special cases.
	return {
		{ "update", "updated", updated },
		{ "add", "added", added },
		{ "remove", "removed", removed },
	}
end

-- Turn the diff into a commit message: a subject naming the plugins while the
-- list is short enough to read in `git log --oneline`, counts when it isn't,
-- and a body that always spells out every plugin and sha.
local function build_message(groups)
	local total, width = 0, 0
	for _, group in ipairs(groups) do
		total = total + #group[3]
		for _, e in ipairs(group[3]) do
			width = math.max(width, #e.name)
		end
	end
	if total == 0 then
		return nil
	end

	local named, counted = {}, {}
	for _, group in ipairs(groups) do
		local verb, past, entries = group[1], group[2], group[3]
		if #entries > 0 then
			local names = vim.tbl_map(function(e)
				return e.name
			end, entries)
			table.insert(named, verb .. " " .. table.concat(names, ", "))
			table.insert(counted, ("%d %s"):format(#entries, past))
		end
	end

	local subject = "chore(lazy): " .. table.concat(named, "; ")
	if total > 3 or #subject > 72 then
		subject = "chore(lazy): " .. table.concat(counted, ", ")
	end

	local body = {}
	for _, group in ipairs(groups) do
		local past, entries = group[2], group[3]
		if #entries > 0 then
			table.insert(body, past .. ":")
			for _, e in ipairs(entries) do
				-- Updates show the move; additions and removals show one sha.
				local sha = (e.from and e.to) and (short(e.from) .. " -> " .. short(e.to))
					or short(e.to or e.from)
				table.insert(body, ("  %-" .. width .. "s  %s"):format(e.name, sha))
			end
		end
	end

	return subject .. "\n\n" .. table.concat(body, "\n"), body
end

-- Paths staged in the parent's index, excluding `ignore`. Only the index is
-- worth checking there: `git commit -- <path>` takes its content from the
-- working tree, so unstaged edits and moved sibling submodules can never be
-- swept into our commit. Anything already staged is work in progress, so we
-- leave the parent alone rather than commit around it.
local function staged_changes(cwd, ignore)
	local code, out = git(cwd, { "diff", "--cached", "--name-only", "--ignore-submodules=dirty", "HEAD" })
	if code ~= 0 then
		return nil
	end
	local staged = {}
	for line in out:gmatch("[^\r\n]+") do
		if line ~= ignore then
			table.insert(staged, line)
		end
	end
	return staged
end

-- Whether the parent is safe to commit into: on BRANCH, nothing else staged,
-- and its recorded pointer to us still matching our HEAD. If it is already
-- carrying an unrecorded bump, that is pending work a pathspec commit here
-- would quietly adopt. Must run *before* the submodule commit, while the
-- pointer is still expected to match.
local function parent_state(cfg, parent, rel)
	local _, branch = git1(parent, { "branch", "--show-current" })
	if branch ~= BRANCH then
		return false, "not on `" .. BRANCH .. "`"
	end
	local staged = staged_changes(parent, rel)
	if staged == nil then
		return false, "cannot read its index"
	end
	if #staged > 0 then
		return false, "has staged changes: " .. table.concat(staged, ", ")
	end
	local _, recorded = git1(parent, { "rev-parse", "HEAD:" .. rel })
	local _, head = git1(cfg, { "rev-parse", "HEAD" })
	if recorded ~= head then
		return false, ("already out of sync (records %s, we are at %s)"):format(short(recorded), short(head))
	end
	return true
end

local running = false

function M.commit()
	if running then
		return
	end
	running = true
	local ok, err = pcall(function()
		local cfg = vim.fn.stdpath("config")

		local code = git(cfg, { "rev-parse", "--git-dir" })
		if code ~= 0 then
			return warn("config dir is not a git repo")
		end

		local others = other_changes(cfg, LOCKFILE)
		if others == nil then
			return warn("cannot read git status")
		end
		if #others > 0 then
			return warn("aborting, other changes present: " .. table.concat(others, ", "))
		end

		if not has_changes(cfg, LOCKFILE) then
			return info("nothing to commit, lockfile matches HEAD")
		end

		-- Work out the parent commit up front so the prompt shows the full plan.
		local parent, rel = superproject(cfg)
		local parent_ok, parent_why = false, nil
		if parent then
			parent_ok, parent_why = parent_state(cfg, parent, rel)
		end

		-- Describe what actually moved. If either side won't parse, or the file
		-- changed without any plugin changing (reformatting), fall back to a
		-- plain dated message rather than skipping the commit.
		local message, body
		local old, new = lock_at_head(cfg), lock_on_disk(cfg)
		if old and new then
			message, body = build_message(diff_locks(old, new))
		end
		message = message or ("chore(lazy): lockfile " .. os.date("%Y-%m-%d"))

		local subject = vim.split(message, "\n")[1]
		local plan = {
			("Commit %s on `%s`?"):format(LOCKFILE, BRANCH),
			"",
			subject,
			"",
		}
		-- Keep the prompt readable when a big update touches dozens of plugins.
		for i, line in ipairs(body or {}) do
			if i > 12 then
				table.insert(plan, ("  … and %d more"):format(#body - 12))
				break
			end
			table.insert(plan, line)
		end
		table.insert(plan, "")
		table.insert(plan, "into " .. vim.fn.fnamemodify(cfg, ":~"))
		if parent_ok then
			table.insert(plan, ("and %s as \"nvim: %s\""):format(vim.fn.fnamemodify(parent, ":~"), subject))
		elseif parent then
			table.insert(plan, ("(%s skipped: %s)"):format(vim.fn.fnamemodify(parent, ":~"), parent_why))
		end

		if vim.fn.confirm(table.concat(plan, "\n"), "&Yes\n&No", 2, "Question") ~= 1 then
			return info("cancelled")
		end

		local branch_ok, reason = ensure_branch(cfg)
		if not branch_ok then
			return warn("aborting, " .. reason)
		end

		local cc, _, cerr = git1(cfg, { "commit", "-q", "-m", message, "--", LOCKFILE })
		if cc ~= 0 then
			return warn("commit failed: " .. cerr)
		end
		info("committed " .. LOCKFILE)

		if not parent_ok then
			return
		end
		-- Record the submodule bump in the parent, and only that path, so any
		-- unrelated work staged there is left untouched.
		if not has_changes(parent, rel) then
			return
		end
		-- Subject only here: the parent just records that the submodule moved,
		-- the per-plugin detail lives in the submodule's own commit.
		local pc, _, perr = git1(parent, { "commit", "-q", "-m", "nvim: " .. subject, "--", rel })
		if pc ~= 0 then
			return warn("parent commit failed: " .. perr)
		end
		info("committed submodule bump in " .. vim.fn.fnamemodify(parent, ":~"))
	end)
	running = false
	if not ok then
		warn("unexpected error: " .. tostring(err))
	end
end

-- A single :Lazy sync fires several of these events, so coalesce them into one
-- prompt and let the Lazy UI finish drawing before we interrupt it.
local pending = nil

function M.setup()
	vim.api.nvim_create_autocmd("User", {
		pattern = { "LazyUpdate", "LazyInstall", "LazySync", "LazyClean" },
		callback = function()
			if pending then
				pending:stop()
			end
			pending = vim.defer_fn(function()
				pending = nil
				M.commit()
			end, 1000)
		end,
	})
end

return M
