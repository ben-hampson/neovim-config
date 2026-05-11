-- Treesitter
--   parses through code using language parsers
--   builds a syntax tree and keeps it updated after every keystroke
--   enables syntax highlighting, folding, text-object manipulation,
--   automatic indentation, incremenetal selection
local disabled_highlight_filetypes = {
  Avante = true,
  AvanteInput = true,
  AvanteSelectedFiles = true,
  AvantePromptInput = true,
  AvanteTodo = true,
  AvanteTodos = true,
}

local disabled_indent_filetypes = {
  yaml = true,
}

local function setup_textobjects()
  require('nvim-treesitter-textobjects').setup({
    select = {
      lookahead = true,
    },
    move = {
      set_jumps = true,
    },
  })

  local select = require('nvim-treesitter-textobjects.select')
  local move = require('nvim-treesitter-textobjects.move')
  local swap = require('nvim-treesitter-textobjects.swap')

  vim.keymap.set({ 'x', 'o' }, 'aa', function()
    select.select_textobject('@parameter.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ia', function()
    select.select_textobject('@parameter.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'af', function()
    select.select_textobject('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'if', function()
    select.select_textobject('@function.inner', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ac', function()
    select.select_textobject('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'x', 'o' }, 'ic', function()
    select.select_textobject('@class.inner', 'textobjects')
  end)

  vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    move.goto_next_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
    move.goto_next_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
    move.goto_next_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
    move.goto_next_end('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    move.goto_previous_start('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
    move.goto_previous_start('@class.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
    move.goto_previous_end('@function.outer', 'textobjects')
  end)
  vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
    move.goto_previous_end('@class.outer', 'textobjects')
  end)

  vim.keymap.set('n', '<leader>a', function()
    swap.swap_next('@parameter.inner')
  end)
  vim.keymap.set('n', '<leader>A', function()
    swap.swap_previous('@parameter.inner')
  end)
end

local function setup_highlighting()
  local group = vim.api.nvim_create_augroup('treesitter-setup', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function(args)
      local filetype = vim.bo[args.buf].filetype
      local lang = vim.treesitter.language.get_lang(filetype)
      if not lang or lang == '' then
        return
      end

      local treesitter = require('nvim-treesitter')
      local available = treesitter.get_available()
      if not vim.tbl_contains(available, lang) then
        return
      end

      local installed = treesitter.get_installed('parsers')
      if not vim.tbl_contains(installed, lang) then
        treesitter.install(lang)
        return
      end

      if not disabled_highlight_filetypes[filetype] then
        pcall(vim.treesitter.start, args.buf, lang)
      end

      if not disabled_indent_filetypes[filetype] then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        config = setup_textobjects,
      },
    },
    init = setup_highlighting,
    config = function()
      require('nvim-treesitter').setup()
    end,
  },
}
