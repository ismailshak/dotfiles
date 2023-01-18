local wezterm = require("wezterm")

local theme = "iceberg-dark"
local dark_bg = "#0e1016"
local colors = wezterm.color.get_builtin_schemes()[theme]
print(colors)

local function get_process(tab)
	local process_icons = {
		["docker"] = {
			{ Foreground = { Color = "#89B4FA" } },
			{ Text = wezterm.nerdfonts.linux_docker },
		},
		["nvim"] = {
			{ Foreground = { Color = "#A6E3A1" } },
			{ Text = wezterm.nerdfonts.custom_vim },
		},
		["vim"] = {
			{ Foreground = { Color = "#A6E3A1" } },
			{ Text = wezterm.nerdfonts.dev_vim },
		},
		["node"] = {
			{ Text = wezterm.nerdfonts.mdi_hexagon },
		},
		["zsh"] = {
			{ Foreground = { Color = "#B4BEFE" } },
			{ Text = wezterm.nerdfonts.dev_terminal },
		},
		["bash"] = {
			{ Text = wezterm.nerdfonts.cod_terminal_bash },
		},
		["cargo"] = {
			{ Text = wezterm.nerdfonts.dev_rust },
		},
		["go"] = {
			{ Foreground = { Color = "#89B4FA" } },
			{ Text = wezterm.nerdfonts.mdi_language_go },
		},
		["git"] = {
			{ Foreground = { Color = "#EBA0AC" } },
			{ Text = wezterm.nerdfonts.dev_git },
		},
		["lua"] = {
			{ Foreground = { Color = "#89B4FA" } },
			{ Text = wezterm.nerdfonts.seti_lua },
		},
		["curl"] = {
			{ Foreground = { Color = "#B4BEFE" } },
			{ Text = wezterm.nerdfonts.mdi_flattr },
		},
		["gh"] = {
			{ Foreground = { Color = "#EBA0AC" } },
			{ Text = wezterm.nerdfonts.dev_github_badge },
		},
	}

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")

	return wezterm.format(process_icons[process_name] or { { Text = string.format("[%s]", process_name) } })
end

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "  ~"
		or string.format("  %s", string.gsub(current_dir, "(.*[/\\])(.*)", "%2"))
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover)
	local edge_background = dark_bg

	if tab.is_active then
		edge_background = colors.background
	end

	return wezterm.format({
		{ Background = { Color = edge_background } },
		{ Attribute = { Intensity = "Half" } },
		{ Text = string.format(" %s  ", tab.tab_index + 1) },
		"ResetAttributes",
		{ Background = { Color = edge_background } },
		{ Text = get_process(tab) },
		{ Text = " " },
		{ Text = get_current_working_dir(tab) },
		{ Foreground = { Color = colors.background } },
		{ Text = "  ▕" },
	})
end)

wezterm.on("update-status", function(window)
	window:set_right_status(wezterm.format({
		{ Text = wezterm.strftime(" %A, %d %B %Y %I:%M %p ") },
	}))
end)

return {
	-- Font & Theme
	color_scheme = theme,
	font = wezterm.font_with_fallback({ "Input Nerd Font", "JetBrains Mono" }),
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
			-- The color of the strip that goes along the top of the window
			-- (does not apply when fancy tab bar is in use)
			background = dark_bg,
		},
	},

	-- Window settings
	window_frame = {
		active_titlebar_bg = "red",
		inactive_titlebar_bg = "red",
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	window_background_opacity = 1.0,
	window_decorations = "RESIZE",

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
