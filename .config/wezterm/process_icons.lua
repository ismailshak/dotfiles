local wezterm = require("wezterm")
local palette = require("colors").palette

local M = {}

M.process_icons = {
	["bash"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.cod_terminal_bash },
	},
	["cargo"] = {
		{ Foreground = { Color = palette.red } },
		{ Text = wezterm.nerdfonts.dev_rust },
	},
	["curl"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.mdi_flattr },
	},
	["docker"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.linux_docker },
	},
	["git"] = {
		{ Foreground = { Color = palette.maroon } },
		{ Text = wezterm.nerdfonts.dev_git },
	},
	["gh"] = {
		{ Foreground = { Color = palette.maroon } },
		{ Text = wezterm.nerdfonts.dev_github_badge },
	},
	["go"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.mdi_language_go },
	},
	["lua"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.seti_lua },
	},
	["node"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.mdi_hexagon },
	},
	["nvim"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.custom_vim },
	},
	["vim"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.dev_vim },
	},
	["zsh"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.dev_terminal },
	},
}

return M
