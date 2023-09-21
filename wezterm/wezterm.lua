-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}
local act = wezterm.action

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end;
-- This is where you actually apply your config choices

config.window_close_confirmation = "NeverPrompt"


-- For example, changing the window decoration:
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- config.window_background_opacity = 1.0 -- Default is 1.0


-- Framerate and curser blink speed
config.animation_fps = 120
config.cursor_blink_rate = 0 -- default is 800
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'


-- tab bar configuration
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false
config.mouse_wheel_scrolls_tabs = false
config.enable_scroll_bar = false
-- Specifies the maximum width that a tab can have in the tab bar when using retro tab mode.
-- It is ignored when using fancy tab mode.
-- Defaults: 16 glyphs in width.
-- config.tab_max_width = 16;
config.window_padding = {
    left = "0%",
    right = "0%",
    top = "0%",
    bottom = "0%",
}


-- font configuration
-- change the font family
config.font = wezterm.font 'JetBrains Mono'
-- change the font size:
config.font_size = 15.0


config.window_frame = {
    font_size = 14.0,
    border_left_width = "0%",
    border_right_width = "0%",
    border_bottom_height = "0%",
    border_top_height = "0%",
}


config.disable_default_key_bindings = true
config.keys = {
    {
        key = 'w',
        mods = 'SHIFT|CTRL',
        action = act.CloseCurrentPane { confirm = false },
    },
    {
        key = 'w',
        mods = 'SHIFT|CTRL',
        action = act.CloseCurrentTab { confirm = false },
    },
    {
        key = 't',
        mods = 'SHIFT|CTRL',
        action = act.SpawnTab 'CurrentPaneDomain',
    },
    {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = act.ActivateTabRelative(1),
    },
    {
        key = 'h',
        mods = 'CTRL|SHIFT',
        action = act.ActivateTabRelative(-1),
    },
}

-- and finally, return the configuration to wezterm
return config;
