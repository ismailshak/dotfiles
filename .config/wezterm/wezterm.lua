local wezterm = require("wezterm")
local helpers = require("helpers")
local colors = require("colors")
local palette = colors.palette
local theme = colors.theme

wezterm.on("format-tab-title", helpers.format_tab_title)
wezterm.on("update-status", helpers.set_status)

return {
	-- Font & Theme
	color_scheme = theme,
	font = wezterm.font_with_fallback({ "CommitMono Nerd Font", "Input Nerd Font", "JetBrains Mono" }),
	font_size = 14.0,

	-- Tab settings
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	enable_scroll_bar = false,
	tab_bar_at_bottom = true,
	show_new_tab_button_in_tab_bar = false,
	tab_max_width = 50,
	colors = {
		tab_bar = {
			-- The color of the strip that goes along the top/bottom of the window
			-- (does not apply when fancy tab bar is in use)
			background = palette.dark_bg,
		},
	},

	-- Window settings
	initial_rows = 50,
	initial_cols = 160,
	adjust_window_size_when_changing_font_size = false,
	window_background_opacity = 1.0,
	window_decorations = "RESIZE",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},

	-- Key bindings
	leader = { key = ",", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action.SplitPane({ direction = "Right", size = { Percent = 50 } }),
		},
		{
			key = "s",
			mods = "LEADER|SHIFT",
			action = wezterm.action.SplitPane({ direction = "Down", size = { Percent = 30 } }),
		},
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action.CloseCurrentPane({ confirm = false }),
		},
		{
			key = "f",
			mods = "LEADER",
			action = wezterm.action.ToggleFullScreen,
		},
		{ key = "L", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
	},
}
