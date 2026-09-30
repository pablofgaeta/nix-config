local uv = vim.uv or vim.loop
local orig_copyfile = uv.fs_copyfile
uv.fs_copyfile = function(src, dst, flags)
	if type(src) == "string" and src:match("nvim%-pack%-lock%.json$") then
		local sf = io.open(src, "r")
		local df = io.open(dst, "r")
		local sdata = sf and vim.json.decode(sf:read("*a")) or { plugins = {} }
		local ddata = df and vim.json.decode(df:read("*a")) or { plugins = {} }
		if sf then
			sf:close()
		end
		if df then
			df:close()
		end
		local merged = vim.tbl_deep_extend("force", ddata.plugins or {}, sdata.plugins or {})
		local out = io.open(dst, "w")
		if out then
			out:write(vim.json.encode({ plugins = merged }))
			out:close()
			uv.fs_copyfile = orig_copyfile
			return true
		end
	end
	return orig_copyfile(src, dst, flags)
end

local M = {}

-- Optional overlay hook: a sibling aspect can add its own runtime path (via
-- programs.pgvim.extraRuntimePaths) providing a `pgvim-overlay` module with
-- before()/after() to extend these lifecycle hooks without this file knowing
-- what the overlay does.
local function overlay()
	local ok, mod = pcall(require, "pgvim-overlay")
	return ok and mod or nil
end

function M.before()
	local ov = overlay()
	if ov and ov.before then
		return ov.before()
	end
	return {}
end

function M.after()
	require("svelte").setup()
	local ov = overlay()
	if ov and ov.after then
		ov.after()
	end
end

return M
