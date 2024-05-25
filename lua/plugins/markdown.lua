return {
  'jakewvincent/mkdnflow.nvim',
  config = function()
    require('mkdnflow').setup({
      mappings = {
        MkdnEnter = { { 'i', 'n', 'v' }, '<CR>' },
        MkdnToggleToDo = { { 'n', 'v' }, '<C-k>' },
      },
      to_do = {
        symbols = { ' ', '-', 'x' },
      },
    })
    vim.api.nvim_create_autocmd("BufLeave", { pattern = "*.md", command = "silent! w" })
  end
}
