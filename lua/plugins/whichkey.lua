return {
    -- Useful plugin to show you pending keybinds.
    {
        'folke/which-key.nvim',
        config = {
            triggers_blacklist = {
                i = { "f" },
                v = { "f" }
            },
        }
    }
}
