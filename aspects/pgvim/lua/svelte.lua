local M = {}

function M.setup()
	vim.filetype.add({
		extension = {
			svelte = "svelte",
		},
	})

	local ok, treesitter = pcall(require, "nvim-treesitter")
	if ok then
		treesitter.install({ "svelte" })
	end

	local capabilities = require("blink.cmp").get_lsp_capabilities()
	vim.lsp.config("svelte", {
		capabilities = capabilities,
	})
	vim.lsp.enable("svelte")
end

return M
