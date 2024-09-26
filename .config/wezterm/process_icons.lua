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
		{ Text = wezterm.nerdfonts.md_bat },
	},
	["beam.smp"] = {
		{ Foreground = { Color = palette.purple } },
		{ Text = wezterm.nerdfonts.custom_elixir },
	},
	["cargo"] = {
		{ Foreground = { Color = palette.red } },
		{ Text = wezterm.nerdfonts.md_language_rust },
	},
	["cargo-watch"] = {
		{ Foreground = { Color = palette.red } },
		{ Text = wezterm.nerdfonts.md_language_rust },
	},
	["cbonsai"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.md_tree },
	},
	["curl"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.cod_terminal_cmd },
	},
	["docker"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.linux_docker },
	},
	["dune"] = {
		{ Foreground = { Color = palette.orange } },
		{ Text = wezterm.nerdfonts.seti_ocaml },
	},
	["fd"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.md_magnify },
	},
	["find"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.md_magnify },
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
		{ Text = wezterm.nerdfonts.md_language_go },
	},
	["htop"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.cod_server },
	},
	["lazydocker"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.linux_docker },
	},
	["lazygit"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.dev_git_compare },
	},
	["lua"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.seti_lua },
	},
	["node"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.md_hexagon },
	},
	["Python"] = {
		{ Foreground = { Color = palette.yellow } },
		{ Text = wezterm.nerdfonts.dev_python },
	},
	["psql"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.md_elephant },
	},
	["nvim"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.custom_vim },
	},
	["rsync"] = {
		{ Foreground = { Color = palette.maroon } },
		{ Text = wezterm.nerdfonts.md_cloud_sync },
	},
	["rsync.samba"] = {
		{ Foreground = { Color = palette.maroon } },
		{ Text = wezterm.nerdfonts.md_cloud_sync },
	},
	["ruby"] = {
		{ Foreground = { Color = palette.red } },
		{ Text = wezterm.nerdfonts.dev_ruby_rough },
	},
	["slides"] = {
		{ Foreground = { Color = palette.blue } },
		{ Text = wezterm.nerdfonts.md_presentation },
	},
	["spotify_player"] = {
		{ Foreground = { Color = palette.green } },
		{ Text = wezterm.nerdfonts.md_spotify },
	},
	["ssh"] = {
		{ Foreground = { Color = palette.lavender } },
		{ Text = wezterm.nerdfonts.md_ssh },
	},
	["transit"] = {
		{ Text = "🚇" },
	},
	["wslhost.exe"] = {
		{ Text = "🐧" },
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
