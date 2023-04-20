-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end
-- This is where you actually apply your config choices



-- For example, changing the window decoration:
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.8



-- tab bar configuration
config.enable_tab_bar = true;
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = true

config.tab_bar_at_bottom = false
-- Specifies the maximum width that a tab can have in the tab bar when using retro tab mode.
-- It is ignored when using fancy tab mode.
-- Defaults: 16 glyphs in width.
config.tab_max_width = 16




-- font configuration
-- change the font family
config.font = wezterm.font 'JetBrains Mono'

-- change the font size:
config.font_size = 13



-- color configuration
-- change the color scheme
-- 'tokyonight_day'
config.color_scheme = 'ayu_light'



-- and finally, return the configuration to wezterm
return config

