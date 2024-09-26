local wezterm = require("wezterm")
local helpers = require("helpers")
local colors = require("colors")
local palette = colors.palette
local theme = colors.theme

wezterm.on("format-window-title", helpers.format_window_title)
wezterm.on("format-tab-title", helpers.format_tab_title)
wezterm.on("update-status", helpers.set_status)

return {
	-- Wezterm updates
	check_for_updates = false,

	-- System bell
	audible_bell = "Disabled",

	-- Launch process
	default_domain = helpers.get_domain(),

	-- Font & Theme
	color_scheme = theme,
	font = helpers.get_font(),
	font_size = helpers.get_initial_font_size(),

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
	initial_rows = helpers.get_initial_size().rows,
	initial_cols = helpers.get_initial_size().cols,
	adjust_window_size_when_changing_font_size = false,
	window_background_opacity = 1.0,
	window_decorations = helpers.get_window_decorations(),
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
			key = "h",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "j",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
		{
			key = "l",
			mods = "CTRL|SHIFT",
			action = wezterm.action.ActivatePaneDirection("Right"),
		},
		{
			key = "f",
			mods = "LEADER",
			action = wezterm.action.ToggleFullScreen,
		},
		{
			key = "L",
			mods = "SHIFT|CTRL",
			action = wezterm.action.ShowDebugOverlay,
		},
	},
}
