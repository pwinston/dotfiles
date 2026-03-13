local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 15

package.path = wezterm.home_dir .. '/.config/canopy/?.lua;' .. package.path
require('canopy').setup(config)

return config
