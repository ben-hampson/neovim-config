return {
  {
    "folke/tokyonight.nvim",
    config = {
      lazy = false,
      priority = 1000,
      opts = {},
      style = "night",
      on_colors = function(colors)
        colors.border = "#565f89"
      end
    }
  }
}
