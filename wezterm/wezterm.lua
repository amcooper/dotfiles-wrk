-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration
local config = wezterm.config_builder()

-- This is where you actually apply your config changes
-- For example, changing the color scheme:
config.color_scheme = 'Modus-Vivendi-Tinted'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font '0xProto Nerd Font'
config.font_size = 14
config.mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

wezterm.on('augment-command-palette', function(window, pane)
    return {
        {
            brief = 'Rename tab',
            icon = 'md_rename_box',

            action = act.PromptInputLine {
                description = 'Enter new name for tab',
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            },
        },
    }
end)

return config
