local wezterm = require("wezterm")
local utils = require("utils")

local M = {}

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function M.get_system_background()
	if not utils.is_macos() then
		return "Dark"
	end

	if wezterm.gui then
		return wezterm.gui.get_appearance():find("Dark") and "Dark" or "Light"
	end
	return "Dark"
end

function M.get_default_theme()
	if M.get_system_background() == "Dark" then
		return "iceberg-dark"
	else
		return "iceberg-light"
	end
end

M.theme = M.get_default_theme()

local scheme_colors = wezterm.color.get_builtin_schemes()[M.theme]

M.light_palette = {
	-- theme related
	dark_bg = "#cad0de",
	light_bg = "#818596",
	grey_bg = "#2E313F",
	background = scheme_colors.background,

	dark_fg = "#17171C",
	grey_fg = "#979aa8",

	-- specific colors
	red = "#D14A32",
	green = "#92c68d",
	blue = "#89B4FA",
	orange = "#DD9344",
	purple = "#4E2A8E",
	yellow = "#F9DC66",
	maroon = "#EBA0AC",
	lavender = "#929acc",
}

M.dark_palette = {
	-- theme related
	dark_bg = "#0E1016",
	light_bg = "#818596",
	grey_bg = "#2E313F",
	background = scheme_colors.background,

	dark_fg = "#17171C",
	grey_fg = "#979aa8",

	-- specific colors
	red = "#D14A32",
	green = "#A6E3A1",
	blue = "#89B4FA",
	orange = "#DD9344",
	purple = "#4E2A8E",
	yellow = "#F9DC66",
	maroon = "#EBA0AC",
	lavender = "#B4BEFEEFE",
}

M.palette = M.get_system_background() == "Dark" and M.dark_palette or M.light_palette

return M
