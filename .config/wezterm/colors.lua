local wezterm = require("wezterm")

local M = {}

M.theme = "iceberg-dark"

local scheme_colors = wezterm.color.get_builtin_schemes()[M.theme]

M.palette = {
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

return M
