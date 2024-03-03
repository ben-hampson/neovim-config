-- Autocompletion
return {

  -- nvim-cmp: the main engine
  {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require('lspkind')
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<C-e>'] = cmp.mapping.close {},
          ['<C-y>'] = cmp.mapping.confirm {
            -- ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },

          -- Tab to expand or jump to fields
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Shift-tab to reverse
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          -- The order you list them here ranks the priority in the dropdown
          { name = 'nvim_lsp', keyword_length = 0, max_item_count=10 },
          { name = 'luasnip',  keyword_length = 3 , max_item_count=10 },
          { name = 'nvim_lua', keyword_length = 3 , max_item_count=10 },
          { name = 'path',     keyword_length = 3 , max_item_count=10 },
          { name = 'buffer',   keyword_length = 5 , max_item_count=10 },
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = lspkind.cmp_format {
            mode = 'symbol',
            with_text = true,
            menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[LuaSnip]",
              nvim_lua = "[Lua]",
              path = "[Path]",
            })
          }
        },
        experimental = {
          ghost_text = true,
          native_menu = false
        }
      }
    end,

    dependencies = {
      -- LuaSnip enables the ability to load VS Code snippets from friendly-snippets
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Neovim lua function completions
      'hrsh7th/cmp-nvim-lua',

      -- Buffer text autocompletion
      'hrsh7th/cmp-buffer',

      -- Path autocompletion
      'hrsh7th/cmp-path',

      -- friendly-snippets provides a lot of snippets via LuaSnip
      -- https://github.com/rafamadriz/friendly-snippets/wiki
      --    Wiki containing list of available snippets for each language
      --    Info on how to enable snippets for frameworks like Django and React
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
    }
  }
}
