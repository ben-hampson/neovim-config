return {
  -- Automatically configures lua_ls to include Neovim config, Neovim runtime, and plugin directories.
  -- Provides completion of Vim functions, Neovim API functions, vim.opt, and vim.loop.
  -- Provides completion for all installed plugins.
  "folke/neodev.nvim",
  opts = {},
  config = {
    library =
    {
      enabled = true,
      plugins = true,
      types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      runtime = true
    },
    lspconfig = true,
    pathStrict = true
  }
}
