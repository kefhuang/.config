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
config.use_fancy_tab_bar = false
config.tab_max_width = 64
config.window_frame = {
  font = wezterm.font({ family = 'Maple Mono NF CN', weight = 'Bold' }),
  font_size = 14,
  active_titlebar_bg = '#1e1e2e',
  inactive_titlebar_bg = '#1e1e2e',
  border_top_height = '0.3cell',
  border_top_color = '#1e1e2e',
}
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
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

local function get_host(pane)
  local cwd = pane.current_working_dir
  if cwd then
    local host = tostring(cwd):match('^file://([^/]+)')
    if host then return host:lower() end
  end
  local title = pane.title
  local h = title:match('^%w+@([^:]+)') or title:match('^([^:]+)') or wezterm.hostname()
  return h:lower()
end

local function shrink_path(path, max_len)
  if #path <= max_len then return path end

  local prefix = ''
  local rest = path
  if rest:sub(1, 2) == '~/' then
    prefix = '~/'
    rest = rest:sub(3)
  elseif rest:sub(1, 1) == '/' then
    prefix = '/'
    rest = rest:sub(2)
  else
    return path
  end

  local parts = {}
  for part in rest:gmatch('[^/]+') do
    table.insert(parts, part)
  end
  if #parts <= 1 then return path end

  for i = 1, #parts - 1 do
    parts[i] = parts[i]:sub(1, 1)
    local result = prefix .. table.concat(parts, '/')
    if #result <= max_len then return result end
  end
  return prefix .. table.concat(parts, '/')
end

wezterm.on('format-tab-title', function(tab, tabs)
  local title = tab.active_pane.title
  title = title:gsub('^%w+@[^:]+:%s*', ''):gsub('^[^:]+:%s*', '')
  local curr_host = get_host(tab.active_pane)
  local show_host = tab.tab_index == 0
  if not show_host and tab.tab_index > 0 then
    local prev_host = get_host(tabs[tab.tab_index].active_pane)
    show_host = prev_host ~= curr_host
  end
  local max_title = 32
  title = shrink_path(title, max_title)
  if show_host then
    title = curr_host .. ': ' .. title
  end
  if tab.is_active then
    return {
      { Text = ' ' },
      { Attribute = { Underline = 'Single' } },
      { Text = title },
      { Attribute = { Underline = 'None' } },
      { Text = ' ' },
    }
  end
  return { { Text = ' ' .. title .. ' ' } }
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
