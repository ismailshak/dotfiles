local wezterm = require("wezterm")

local M = {}

M.process_icons = {
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

return M
