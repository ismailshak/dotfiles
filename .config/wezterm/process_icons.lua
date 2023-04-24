local wezterm = require("wezterm")
local palette = require("colors").palette

local M = {}

M.process_icons = {
	["aws"] = {
		{ Foreground = { Color = palette.orange } },
		{ Text = wezterm.nerdfonts.dev_aws },
	},
	["bash"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.cod_terminal_bash },
	},
	["bat"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.mdi_page_first },
	},
	["beam.smp"] = {
		{ Foreground = { Color = palette.purple } },
		{ Text = wezterm.nerdfonts.custom_elixir },
	},
	["cargo"] = {
		{ Foreground = { Color = palette.red } },
		{ Text = wezterm.nerdfonts.dev_rust },
	},
	["curl"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.cod_terminal_cmd },
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
	["Python"] = {
		{ Foreground = { Color = palette.yellow } },
		{ Text = wezterm.nerdfonts.dev_python },
	},
	["psql"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.mdi_elephant },
	},
	["nvim"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.custom_vim },
	},
	["ssh"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.cod_terminal },
	},
	["transit"] = {
		{ Text = "🚇" },
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
