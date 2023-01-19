local wezterm = require("wezterm")
local palette = require("colors").palette

local M = {}

M.get_current_working_dir = function(tab)
	return tab.active_pane.current_working_dir
end

M.format_tab_dir = function(current_dir)
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "  ~" or string.format("%s", string.gsub(current_dir, "(.*[/\\])(.*)", "%2"))
end

M.get_process = function(tab)
	local process_icons = require("process_icons").process_icons
	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")

	return wezterm.format(process_icons[process_name] or { { Text = string.format("[%s]", process_name) } })
end

M.format_tab_title = function(tab)
	local edge_background = palette.dark_bg

	if tab.is_active then
		edge_background = palette.background
	end

	local current_dir = M.get_current_working_dir(tab)

	return wezterm.format({
		{ Background = { Color = edge_background } },
		{ Attribute = { Intensity = "Half" } },
		{ Text = string.format(" %s  ", tab.tab_index + 1) },
		"ResetAttributes",
		{ Background = { Color = edge_background } },
		{ Text = M.get_process(tab) },
		{ Text = " " },
		{ Text = M.format_tab_dir(current_dir) },
		{ Foreground = { Color = palette.background } },
		{ Text = "  ▕" },
	})
end

M.set_status = function(window)
	window:set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Half" } },
		{ Text = wezterm.strftime(" %A, %d %B %Y %I:%M %p ") },
	}))
end

return M
