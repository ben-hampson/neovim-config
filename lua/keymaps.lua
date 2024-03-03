-- Keymaps
-- See `:help vim.keymap.set()`

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Unmaps
vim.api.nvim_set_keymap('n', '<leader>j', '<Nop>', {noremap = true})

-- Keymaps for better default experience
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('i', 'jk', '<esc>', { silent = true })
-- vim.keymap.set('v', 'jk', '<esc>', { silent = true })
vim.keymap.set('n', 'H', '^', { silent = true })
vim.keymap.set('n', 'L', '$', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Buffer
vim.keymap.set('n', "bn", ":bn<CR>", { silent = true, desc = "Buffer Next"})
vim.keymap.set('n', "bp", ":bp<CR>", { silent = true, desc = "Buffer Previous"})
vim.keymap.set('n', "bq", ":Bdelete<CR>", { silent = true, desc = "Buffer Quit"})

-- NvimTree Toggle
vim.keymap.set('n', "<C-E>", ":NvimTreeToggle<CR>", { silent = true, desc = "NvimTree Toggle"})

-- Remap because we want <C-k> for moving the cursor up one window
vim.keymap.set('n', "<C-m>", vim.lsp.buf.signature_help, { silent = true, desc = "Signature Help"})
