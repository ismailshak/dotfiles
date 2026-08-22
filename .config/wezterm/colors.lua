local wezterm = require("wezterm")
local utils = require("utils")

local M = {}

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function M.get_system_background()
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
	lavender = "#B4BEFE",
}

M.palette = M.get_system_background() == "Dark" and M.dark_palette or M.light_palette

-- Returns a color partway between the scheme's foreground and background,
-- used to emulate reduced opacity for dim (SGR 2) text since wezterm has no
-- built-in opacity/color handling for dim -- only font weight substitution.
function M.mid_color()
	local fr, fg, fb = wezterm.color.parse(scheme_colors.foreground):srgba_u8()
	local br, bg, bb = wezterm.color.parse(scheme_colors.background):srgba_u8()
	return string.format(
		"#%02x%02x%02x",
		math.floor((fr + br) / 2),
		math.floor((fg + bg) / 2),
		math.floor((fb + bb) / 2)
	)
end

return M
