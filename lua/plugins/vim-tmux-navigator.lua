return {
  -- Move neovim panes with C-h / j / k / l
  -- And move from neovim to tmux pane and back, if one is open
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Go to the previous pane" },
      { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Got to the left pane" },
      { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Got to the down pane" },
      { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Got to the up pane" },
      { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Got to the right pane" },
    },
  },
}
