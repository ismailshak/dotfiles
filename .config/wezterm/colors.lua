local wezterm = require("wezterm")

local M = {}

M.theme = "iceberg-dark"

local scheme_colors = wezterm.color.get_builtin_schemes()[M.theme]

M.palette = {
	-- theme related
	dark_bg = "#0E1016",
	background = scheme_colors.background,

	-- specific colors
	red = "D14A32",
	green = "A6E3A1",
	blue = "#89B4FA",
	maroon = "#EBA0AC",
	lavender = "#B4BEFE",
}

return M
