local wezterm = require 'wezterm'
local act = wezterm.action

local home = wezterm.home_dir

-- Hostname -> projects module mapping
local machine_map = {
  ['pbw24.lan'] = 'projects-home',
}

local hostname = wezterm.hostname()
local projects_module = machine_map[hostname] or 'projects-work'
local projects = require(projects_module)(home)

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

-- claude workspace: claude, shell1, shell2
local function claude_workspace(name, dir)
  local tab, pane, window = wezterm.mux.spawn_window {
    workspace = name,
    cwd = dir,
  }
  tab:set_title('claude')
  pane:send_text('claude\n')

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

local workspace_creators = {
  orson = orson_workspace,
  claude = claude_workspace,
  simple = simple_workspace,
}

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  return wezterm.mux.get_active_workspace() .. ' - ' .. tab.active_pane.title
end)

wezterm.on('gui-startup', function()
  for _, p in ipairs(projects.projects) do
    local creator = workspace_creators[p.type] or simple_workspace
    creator(p.name, p.dir)
  end
  wezterm.mux.set_active_workspace(projects.default)
end)

-- Build keybindings from project list
local keys = {
  { key = 'Space', mods = 'CTRL', action = act.ShowLauncher },
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\n' },
}

for _, p in ipairs(projects.projects) do
  if p.key then
    table.insert(keys, {
      key = p.key,
      mods = 'CTRL|SHIFT',
      action = act.SwitchToWorkspace { name = p.name },
    })
  end
end

return {
  font_size = 15,
  keys = keys,
}
