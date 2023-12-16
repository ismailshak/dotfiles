local wezterm = require("wezterm")
local palette = require("colors").palette
local utils = require("utils")

local M = {}

function M.get_domain()
	if utils.is_windows() then
		return "WSL:Ubuntu"
	end

	return "local"
end

function M.get_current_working_dir(tab)
	return tab.active_pane.current_working_dir
end

function M.get_font()
	if utils.is_windows() then
		return wezterm.font("Input Nerd Font")
	end

	return wezterm.font("CommitMono Nerd Font")
end

function M.get_window_decorations()
	if utils.is_windows() then
		return "TITLE | RESIZE"
	end

	return "RESIZE"
end

function M.get_initial_font_size()
	if utils.is_macos() then
		return 18.0
	end

	return 12.0
end

function M.get_initial_size()
	if utils.is_macos() then
		return {
			rows = 50,
			cols = 160,
		}
	end

	return {
		rows = 40,
		cols = 120,
	}
end

function M.format_tab_dir(current_dir)
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "  ~" or string.format("%s", string.gsub(current_dir, "(.*[/\\])(.*)", "%2"))
end

function M.get_process(tab)
	local process_icons = require("process_icons").process_icons
	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")

	return wezterm.format(process_icons[process_name] or { { Text = string.format("[%s]", process_name) } })
end

function M.format_window_title(tab, pane, tabs, panes, config)
	return "wezterm"
end

function M.format_tab_title(tab)
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

function M.get_battery_icon(percentage, state)
	local icon = wezterm.nerdfonts.fa_battery_empty
	if percentage > 0.99 then
		icon = wezterm.nerdfonts.fa_battery_full
	elseif percentage > 0.74 then
		icon = wezterm.nerdfonts.fa_battery_three_quarters
	elseif percentage > 0.49 then
		icon = wezterm.nerdfonts.fa_battery_half
	elseif percentage > 0.24 then
		icon = percentage > wezterm.nerdfonts.fa_battery_quarter
	end

	if state == "Charging" and percentage < 1.0 then
		icon = wezterm.nerdfonts.fa_bolt .. " " .. icon
	end

	if state == "Full" or (state == "Charging" and percentage == 1.0) then
		icon = wezterm.nerdfonts.mdi_power_plug .. " " .. icon
	end

	return icon
end

function M.set_status(window)
	local battery = wezterm.battery_info()[1]
	local battery_icon = M.get_battery_icon(battery.state_of_charge, battery.state)
	window:set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Half" } },
		{ Text = wezterm.strftime(" %a %b %-d %I:%M%P ") },
		{ Foreground = { Color = palette.dark_fg } },
		{ Background = { Color = palette.light_bg } },
		{ Text = " " .. battery_icon .. "  " },
	}))
end

return M
