-- LSP Configuration & Plugins
return {
  -- Automatically install LSPs, formatters, linters, and DAPs to stdpath for neovim
  {
    "williamboman/mason.nvim",
    config = true,
  },

  -- Installs LSPs automatically using Mason.
  -- Translates between lspconfig LSP names and Mason package names.
  -- Ensures LSPs have a good config to pass to the builtin Neovim LSP client.
  {
    "williamboman/mason-lspconfig.nvim",
    config = {
      ensure_installed = {
        -- Automatically installs these LSPs.
        -- Use the shortened names. Shown in light grey in :Mason.
        -- For list of lspconfigs available -> ':h lspconfig-all'

        -- "pyright",  -- Python: go to definition, references, show function signature in hover
        "pylsp",
        "ruff_lsp", -- Python: Used by none-ls -> Formatting, linting
        "lua_ls",
        "terraformls",
      },
    }
  },

  -- nvim-lspconfig is a collection of configs for the Nvim LSP Client.
  -- These configs enable the Nvim LSP Client to connect to the language servers.
  -- It is not the Nvim LSP Client itself. For that, see ':h lspconfig'
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Must specify LSP configs below in order for them to work.

      -- If poetry env is set up, get pyright to use that
      local util = require('lspconfig/util')
      local path = util.path

      local function get_python_path(workspace)
        -- Use activated virtualenv.
        if vim.env.VIRTUAL_ENV then
          return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
        end

        -- Find and use virtualenv via poetry in workspace directory.
        local match = vim.fn.glob(path.join(workspace, 'poetry.lock'))
        if match ~= '' then
          local venv = vim.fn.trim(vim.fn.system('poetry env info -p'))
          return path.join(venv, 'bin', 'python')
        end

        -- Fallback to system Python.
        return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
      end

      -- Enable LSP autocompletion capabilities
      -- When you complete and use a function, it will add it to imports
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- lspconfig.pyright.setup({
      --   on_attach = function()
      --     require 'lsp_signature'.on_attach {
      --       hint_enable = false,
      --     }
      --   end,
      --   on_init = function(client)
      --     client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
      --   end,
      --   capabilities = capabilities
      -- })

      lspconfig.pylsp.setup({
        capabilities = capabilities,
        -- capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
        -- settings = {
        --   pylsp = {
        --     plugins = {
        --       jedi_completion = {
        --         include_params = true,
        --       },
        --     },
        --   },
        -- },
      })

      lspconfig.ruff_lsp.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace"
            }
          }
        }
      })
      lspconfig.terraformls.setup({
        capabilities = capabilities
      })

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "LSP: Get to Declaration" })
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = "LSP: Go to Definition" })
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition,
            { buffer = ev.buf, desc = "LSP: Go to Type Definition" })
          -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = ev.buf, desc = "LSP: References" })
          vim.keymap.set('n', 'gr', "<CMD>:Telescope lsp_references theme=ivy<CR>",
            { buffer = ev.buf, desc = "LSP: References list" })
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = "LSP: Implementations" })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover,
            { buffer = ev.buf, desc = "LSP: Hover symbol information" })

          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder,
            { buffer = ev.buf, desc = "LSP: Add workspace folder" })
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder,
            { buffer = ev.buf, desc = "LSP: Remove workspace folder" })
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, { buffer = ev.buf, desc = "LSP: List workspace folders" })

          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, { buffer = ev.buf, desc = "LSP: Rename symbol" })
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action,
            { buffer = ev.buf, desc = "LSP: Code action" })
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, { buffer = ev.buf, desc = "LSP: Format" })
        end,
      })

      -- Format when saving buffer
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          vim.lsp.buf.format()
        end
      })

      -- Border around vim.buf.lsp.hover
      local _border = "single"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = _border
        }
      )

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
          border = _border
        }
      )

      vim.diagnostic.config {
        float = { border = _border }
      }
    end,
  },

  -- Useful status updates for LSP
  -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
  { "j-hui/fidget.nvim", tag = "legacy", opts = {} },

  -- Additional lua configuration, makes nvim stuff amazing!
  { "folke/neodev.nvim" },

  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "VeryLazy",
  --   opts = {},
  --   config = function(_, opts) require 'lsp_signature'.setup(opts) end
  -- }
}
