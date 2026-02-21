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

-- Slightly transparent and blurred background
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = 'RESIZE | INTEGRATED_BUTTONS'
config.window_frame = {
  font = wezterm.font({ family = 'Maple Mono NF CN', weight = 'Bold' }),
  font_size = 11,
}

-- Use the right side of the status bar
wezterm.on('update-status', function(window)
  -- Grab the utf8 character for the "powerline" left facing
  -- solid arrow.
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Grab the current window's configuration, and from it the
  -- palette (this is the combination of your chosen colour scheme
  -- including any overrides).
  local color_scheme = window:effective_config().resolved_palette
  local bg = color_scheme.background
  local fg = color_scheme.foreground

  window:set_right_status(wezterm.format({
    -- First, we draw the arrow...
    { Background = { Color = 'none' } },
    { Foreground = { Color = bg } },
    { Text = SOLID_LEFT_ARROW },
    -- Then we draw our text
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = ' ' .. wezterm.hostname() .. ' ' },
  }))
end)

-- Table mapping keypresses to actions
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

-- To check the system: https://wezterm.org/config/lua/wezterm/target_triple.html
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  -- IMPORTANT: Sets WSL2 UBUNTU as the defualt when opening Wezterm
  config.default_domain = 'WSL:Ubuntu'
end

return config
