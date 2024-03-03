-- nvim-tree - Filetree
-- Maybe NeoTree is better?
return {
  {'nvim-tree/nvim-tree.lua',
  config = -- config is passed into require("PLUGIN").setup()
    {
      update_focused_file = {
        enable = true,
      },
      filters = {
        dotfiles = false,
        git_ignored = false
      }
    }
  }
}
