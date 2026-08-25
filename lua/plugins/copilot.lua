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
        accept = '<tab>',
        accept_word = false,
        accept_line = false,
        dismiss = "<esc>",
      },
    copilot_model = "",
    },
  },
}
