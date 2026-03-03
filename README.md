# dotfiles

Personal dotfiles for macOS.

## What's Included

| Tool | Config | Link Method |
|------|--------|-------------|
| zsh | `zsh/zshrc`, `zsh/zprofile` | Sourced from stub files |
| Starship | `starship/starship.toml` | Symlink |
| WezTerm | `wezterm/wezterm.lua`, `wezterm/projects-*.lua` | Symlink |

## New Machine Setup

### 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install tools

```bash
brew install git starship pyenv direnv node@22
```

### 3. Install WezTerm

Download from https://wezfurlong.org/wezterm/installation.html

### 4. Clone and run setup

```bash
git clone git@github.com:pwinston/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## What setup.sh Does

- Creates `~/.zshrc` and `~/.zprofile` stub files that source from this repo
- Symlinks `~/.config/starship.toml` to `starship/starship.toml`
- Symlinks `~/.config/wezterm/*.lua` to `wezterm/*.lua`
- Skips anything that already exists (safe to re-run)

## Structure

```
dotfiles/
├── setup.sh              # Setup script
├── starship/
│   └── starship.toml     # Starship prompt config
├── wezterm/
│   ├── wezterm.lua        # WezTerm config
│   ├── projects-home.lua  # Home machine workspaces
│   └── projects-work.lua  # Work machine workspaces
└── zsh/
    ├── zprofile           # PATH, homebrew, locale
    ├── zshrc              # Aliases, functions, tool init
    └── secrets            # API keys etc. (not committed)
```
