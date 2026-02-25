-- Examples:
-- 1. To log a message (use ctrl+shift+L to view logs):
-- wezterm.log_info("hello world! my name is " .. wezterm.hostname())
local wezterm = require 'wezterm'

-- These are vars to put things in later (i dont use em all yet)
local config = {}
-- This is for newer wezterm versions to use the config builder 
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Catppuccin Mocha'
-- Choose font, make sure it's installed on your machine
config.font = wezterm.font('Maple Mono NF CN')
config.font_size = 13

config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0.5cell',
}
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.window_frame = {
  font = wezterm.font({ family = 'Maple Mono NF CN', weight = 'Bold' }),
  font_size = 14,
  active_titlebar_bg = '#1e1e2e',
  inactive_titlebar_bg = '#1e1e2e',
}
config.window_decorations = 'RESIZE'
config.colors = {
  tab_bar = {
    background = '#1e1e2e',
    active_tab = {
      bg_color = '#1e1e2e',
      fg_color = '#cdd6f4',
    },
    inactive_tab = {
      bg_color = '#1e1e2e',
      fg_color = '#6c7086',
    },
    inactive_tab_hover = {
      bg_color = '#1e1e2e',
      fg_color = '#cdd6f4',
    },
    inactive_tab_edge = '#1e1e2e',
  },
}

local function extract_host(title)
  local host = title:match('^%w+@([^:]+)') or title:match('^([^:]+)')
  return host or ''
end

wezterm.on('format-tab-title', function(tab, tabs)
  local title = tab.active_pane.title
  title = title:gsub('^%w+@', '')
  if tab.tab_index > 0 then
    local prev_title = tabs[tab.tab_index].active_pane.title
    if extract_host(prev_title) == extract_host(tab.active_pane.title) then
      title = title:gsub('^[^:]+:%s*', '')
    end
  end
  return ' ' .. title .. ' '
end)

config.keys = {
  -- Sends ESC + b and ESC + f sequence, which is used
  -- for telling your shell to jump back/forward.
  {
    -- When the left arrow is pressed
    key = 'LeftArrow',
    -- With the "Option" key modifier held down
    mods = 'OPT',
    -- Perform this action, in this case - sending ESC + B
    action = wezterm.action.SendString '\x1bb',
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },
  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action.SpawnCommandInNewWindow{
      cwd = wezterm.home_dir,
      args = { 'code', '-n', wezterm.config_file },
    },
  },
}

return config
