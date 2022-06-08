local status_ok, navigator = pcall(require, "Navigator")
if not status_ok then
	return
end

-- Configuration
require('Navigator').setup({
  -- When you want to save the modified buffers when moving to tmux
  -- nil - Don't save (default)
  -- 'current' - Only save the current modified buffer
  -- 'all' - Save all the buffers
  auto_save = nil,

  -- Disable navigation when tmux is zoomed in
  disable_on_zoom = false
})

-- Keybindings
vim.keymap.set('n', "<c-h>", '<CMD>NavigatorLeft<CR>')
vim.keymap.set('n', "<c-l>", '<CMD>NavigatorRight<CR>')
vim.keymap.set('n', "<c-k>", '<CMD>NavigatorUp<CR>')
vim.keymap.set('n', "<c-j>", '<CMD>NavigatorDown<CR>')
vim.keymap.set('n', "<c-p>", '<CMD>NavigatorPrevious<CR>')