return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  opts = {
    panel = {
      enabled = false,
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = false,
      keymap = {
        accept = '<C-u>',
        accept_word = false,
        accept_line = false,
        dismiss = "<C-]>",
      },
    copilot_model = "",
    },
  },
}
