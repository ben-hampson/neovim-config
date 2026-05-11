-- Set lualine as statusline
return {
  {
    'nvim-lualine/lualine.nvim',
    config = {
      options = {
        theme = "tokyonight",
        disabled_filetypes = {
          'dapui_breakpoints',
          'dapui_watches',
          'dapui_stacks',
          'dapui_scopes',
          'dap-repl',
          'Avante',
          'AvanteInput',
          'AvanteSelectedFiles',
          'AvantePromptInput',
          'AvanteTodo',
          'AvanteTodos',
        },
        ignore_focus = {
          'dapui_breakpoints',
          'dapui_watches',
          'dapui_stacks',
          'dapui_scopes',
          'dap-repl',
          'NvimTree',
          'Avante',
          'AvanteInput',
          'AvanteSelectedFiles',
          'AvantePromptInput',
          'AvanteTodo',
          'AvanteTodos',
        },
      },
    },
  }
}
