-- Set lualine as statusline
return {
  {
    'nvim-lualine/lualine.nvim',
    config = {
      options = {
        theme = "tokyonight",
        disabled_filetypes = { 'dapui_breakpoints', 'dapui_watches', 'dapui_stacks', 'dapui_scopes', 'dap-repl' },
        ignore_focus = { 'dapui_breakpoints', 'dapui_watches', 'dapui_stacks', 'dapui_scopes', 'dap-repl', 'NvimTree' },
      },
    },
  }
}
