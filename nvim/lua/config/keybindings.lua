vim.g.mapleader = " "

local keymap = vim.api.nvim_set_keymap
-- no remap keybindings
local opts = { noremap = true }

-- ctrl+h/j/k/l navigates between split panes
keymap("n", "<c-h>", "<c-w>h", opts)
keymap("n", "<c-j>", "<c-w>j", opts)
keymap("n", "<c-k>", "<c-w>k", opts)
keymap("n", "<c-l>", "<c-w>l", opts)

-- toggle nerd tree (file browser)
keymap("n", "<c-n>", ":NvimTreeToggle <CR>", opts)

-- trigger null-ls formatting and linting
keymap("n", "<leader>lf", ":Format <CR>", opts)
-- keymap('n', '<leader>ll', 'Lint <CR>', opts)
