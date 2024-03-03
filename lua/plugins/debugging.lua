-- Debugging
return
{
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      'theHamsta/nvim-dap-virtual-text' -- Show variable values and types inline.
    },
    config = function()
      require("dapui").setup(
        {
          controls = {
            element = "repl",
            enabled = true,
            icons = {
              disconnect = "",
              pause = "",
              play = "",
              run_last = "",
              step_back = "",
              step_into = "",
              step_out = "",
              step_over = "",
              terminate = ""
            }
          },
          element_mappings = {},
          expand_lines = true,
          floating = {
            border = "single",
            mappings = {
              close = { "q", "<Esc>" }
            }
          },
          force_buffers = true,
          icons = {
            collapsed = "",
            current_frame = "",
            expanded = ""
          },
          layouts = { {
            elements = { {
              id = "scopes",
              size = 0.25
            }, {
              id = "breakpoints",
              size = 0.25
            }, {
              id = "stacks",
              size = 0.25
            }, {
              id = "watches",
              size = 0.25
            } },
            position = "left",
            size = 40
          }, {
            elements = { {
              id = "repl",
              size = 1
            },
            },
            position = "bottom",
            size = 10
          } },
          mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            repl = "r",
            toggle = "t"
          },
          render = {
            indent = 1,
            max_value_lines = 100
          }
        }
      )

      local dap = require("dap")
      local dapui = require("dapui")

      local nvim_tree_api = require("nvim-tree.api")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        nvim_tree_api.tree.close_in_this_tab()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        -- When the debug sessions is terminated due to an error or because the user manually stopped it.
        -- dapui.close()
        -- nvim_tree_api.tree.open()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        -- When the debugee has finished running successfully.
        -- dapui.close()
        -- nvim_tree_api.tree.open()
      end

      -- By default, load .vscode/launch.json as the project debugging configuration. require('vim-tmux-navigator').setup()
      require('dap.ext.vscode').load_launchjs(nil, {})

      -- Debugging Keymaps
      vim.keymap.set('n', '<C-b>', dap.toggle_breakpoint, { silent = true, desc = "Debug: Toggle [B]reakpoint" })
      vim.keymap.set('n', '<C-n>', function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        { desc = "Debug: Toggle Conditional Breakpoint" })
      vim.keymap.set('n', '<F5>', dap.continue, { desc = "Debug: Start / Continue" })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set('n', '<F6>', dap.repl.toggle, { desc = "Debug: Toggle REPL" })
      vim.keymap.set('n', 'dl', dap.run_last, { desc = "[D]ebug [L]ast - run last debug configuration again" })
      vim.keymap.set('n', '<leader>dq', ":lua require'dap'.terminate()<CR> :lua require'dapui'.close()<CR>",
        { desc = "[D]ebug: [Q]uit" })

      -- Breakpoint Symbols
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        desc = "prevent colorscheme clears self-defined DAP icon colors.",
        callback = function()
          vim.api.nvim_set_hl(0, 'DapRed', { ctermbg = 0, fg = '#993939', bg = '#31353f' })   -- red
          vim.api.nvim_set_hl(0, 'DapBlue', { ctermbg = 0, fg = '#61afef', bg = '#31353f' })  -- blue
          vim.api.nvim_set_hl(0, 'DapGreen', { ctermbg = 0, fg = '#98c379', bg = '#31353f' }) -- green
          vim.api.nvim_set_hl(0, 'DapWhite', { ctermbg = 0, fg = '#f9f9f9', bg = '#313131' }) -- white
        end
      })

      -- DapBreakpoint = Breakpoint in place
      vim.fn.sign_define('DapBreakpoint',
        { text = ' ', texthl = 'DapWhite', linehl = '', numhl = '' })
      -- DapBreakpointCondition = Conditional breakpoint in place
      vim.fn.sign_define('DapBreakpointCondition',
        { text = ' ', texthl = 'DapBlue', linehl = 'DapBlue', numhl = 'DapBlue' })
      -- DapStopped = The line the debugger is currently on.
      vim.fn.sign_define('DapStopped',
        { text = '󰁕 ', texthl = 'DapGreen', linehl = 'DapGreen', numhl = 'DapGreen' })

      vim.fn.sign_define('DiagnosticWarn', { text = ' ', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStoppedLine',
        { text = ' ', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected',
        { text = ' ', texthl = 'DapRed', linehl = 'DapRed', numhl = 'DapRed' })
      vim.fn.sign_define('DiagnosticError', { text = ' ', texthl = 'DapRed', linehl = 'DapRed', numhl = 'DapRed' })
      vim.fn.sign_define('DapLogPoint', {
        text = '',
        texthl = 'DapBlue',
        linehl = 'DapBlue',
        numhl =
        'DapBlue'
      })

      require("nvim-dap-virtual-text").setup()
    end
  },

  -- Provides a DAP config to nvim-dap to connect nvim-dap to the debupy debugger.
  -- debugpy will automatically pick-up a virtual environment if it is activated
  -- before neovim is started.
  {
    'mfussenegger/nvim-dap-python',
    config = function()
      require('dap-python').setup('~/.virtualenvs/debugpy/bin/python') -- Uses this virtualenv containing debugpy unless it picks up a virtualenv that's already in use.
      require('dap-python').test_runner = 'pytest'
    end
  },

  {
    'rcarriga/nvim-dap-ui'
  },

  {
    'nvim-neotest/neotest',
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim"
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
        },
      })
      vim.keymap.set('n', "ts", require('neotest').summary.toggle, { silent = true, desc = "[T]est [S]ummary" })
      vim.keymap.set('n', "tf", function() require('neotest').run.run(vim.fn.expand('%')) end,
        { silent = true, desc = "[T]est [F]ile" })
      vim.keymap.set('n', "tF", function() require('neotest').run.run({ vim.fn.expand('%'), strategy = 'dap' }) end,
        { silent = false, desc = "[T]est + Debug [F]ile" }) -- Error expecting luv callback
      vim.keymap.set('n', "tn", require('neotest').run.run, { silent = true, desc = "[T]est [N]earest" })
      vim.keymap.set('n', "tN", function() require('neotest').run.run({ strategy = 'dap' }) end,
        { silent = true, desc = "[T]est + Debug [N]earest" })
      vim.keymap.set('n', "tl", require('neotest').run.run_last, { silent = true, desc = "Run [L]ast Test" })
      vim.keymap.set('n', "tL", function() require('neotest').run.run_last({ strategy = 'dap' }) end,
        { silent = true, desc = "Debug [L]ast Test" })
      vim.keymap.set('n', "to", function() require('neotest').output.open({ enter = true }) end,
        { silent = true, desc = "[T]est [O]utput" })
    end
  },
  { 'nvim-neotest/neotest-python' },
}
