-- Adds git releated signs to the gutter, as well as utilities for managing changes
return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>ghp', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]it [H]unk [P]revious' })
        vim.keymap.set('n', '<leader>ghn', require('gitsigns').next_hunk,
          { buffer = bufnr, desc = '[G]it [H]unk [N]ext' })
        vim.keymap.set('n', '<leader>ghh', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = '[G]it [H]unk Preview' })
        vim.keymap.set('n', '<leader>gb', require('gitsigns').blame, { buffer = bufnr, desc = '[G]it [B]lame' })
        vim.keymap.set('n', '<leader>ghr', require('gitsigns').reset_hunk,
          { buffer = bufnr, desc = '[G]it [H]unk [R]eset' })
      end,
    },
    version = "*"
  }
}
