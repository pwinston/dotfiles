local wezterm = require 'wezterm'
local act = wezterm.action

local home = '/Users/pwinston'

-- create an orson-style workspace: claude, serve, backlot, shell1, shell2
local function orson_workspace(name, dir)
  local tab, pane, window = wezterm.mux.spawn_window {
    workspace = name,
    cwd = dir,
  }
  tab:set_title('claude')
  pane:send_text('claude\n')

  local serve_tab, serve_pane = window:spawn_tab({ cwd = dir })
  serve_tab:set_title('serve')
  serve_pane:send_text('make serve\n')

  local backlot_tab, backlot_pane = window:spawn_tab({ cwd = dir .. '/backlot' })
  backlot_tab:set_title('backlot')
  backlot_pane:send_text('make serve\n')
  window:spawn_tab({ cwd = dir }):set_title('shell1')
  window:spawn_tab({ cwd = dir }):set_title('shell2')

  tab:activate()
end

-- simple workspace: repo, shell1, shell2
local function simple_workspace(name, dir)
  local tab, pane, window = wezterm.mux.spawn_window {
    workspace = name,
    cwd = dir,
  }
  tab:set_title('repo')

  window:spawn_tab({ cwd = dir }):set_title('shell1')
  window:spawn_tab({ cwd = dir }):set_title('shell2')

  tab:activate()
end

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  return wezterm.mux.get_active_workspace() .. ' - ' .. tab.active_pane.title
end)

wezterm.on('gui-startup', function()
  simple_workspace('tobeva', home .. '/tobeva')

  orson_workspace('orson1', home .. '/tobeva/orson')
  orson_workspace('orson2', home .. '/tobeva/orson2')
  orson_workspace('orson3', home .. '/tobeva/orson3')
  orson_workspace('orson4', home .. '/tobeva/orson4')
  orson_workspace('orson5', home .. '/tobeva/orson5')
  orson_workspace('orson6', home .. '/tobeva/orson6')
  orson_workspace('orson7', home .. '/tobeva/orson7')
  orson_workspace('orson8', home .. '/tobeva/orson8')
  orson_workspace('orson9', home .. '/tobeva/orson9')

  simple_workspace('canopy', home .. '/tobeva/canopy')
  wezterm.mux.set_active_workspace('tobeva')
end)

return {
  font_size = 15,
  keys = {
    {
      key = 'Space',
      mods = 'CTRL',
      action = act.ShowLauncher,
    },
    -- CTRL+SHIFT+0: tobeva
    { key = '0', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'tobeva' } },
    -- CTRL+SHIFT+1-9: orson1-9
    { key = '1', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson1' } },
    { key = '2', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson2' } },
    { key = '3', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson3' } },
    { key = '4', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson4' } },
    { key = '5', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson5' } },
    { key = '6', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson6' } },
    { key = '7', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson7' } },
    { key = '8', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson8' } },
    { key = '9', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'orson9' } },
    -- CTRL+SHIFT+C: canopy
    { key = 'c', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace { name = 'canopy' } },
    -- Shift+Enter sends a literal newline
    { key = 'Enter', mods = 'SHIFT', action = act.SendString '\n' },
  },
}
