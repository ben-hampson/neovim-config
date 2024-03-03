return {
	{
		"nvimtools/none-ls.nvim",
		version = "*",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- Ensure these formatters and linters are installed in lsp-config.lua
					-- using mason-lspconfig's ensure_installed table.
					-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md

					-- Python
					null_ls.builtins.diagnostics.ruff,
					null_ls.builtins.formatting.ruff,
				},
			})
		end,
	},
}
