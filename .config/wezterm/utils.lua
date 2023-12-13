local wezterm = require("wezterm")

local M = {}

function M.is_macos()
	return wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin"
end

function M.is_windows()
	return wezterm.target_triple == "x86_64-pc-windows-msvc"
end

return M
