return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = {
      size = 120,
      open_mapping = [[<c-t>]],
      insert_mappings = true, -- mapping applies in insert mode?
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      persist_size = true,
      direction = "float",
      close_on_exit = false,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    }
  }
}
