local wezterm = require("wezterm")

local M = {}

M.theme = "iceberg-dark"

local scheme_colors = wezterm.color.get_builtin_schemes()[M.theme]

M.palette = {
	dark_bg = "#0e1016",
	background = scheme_colors.background,
}

return M
