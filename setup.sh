#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

if [ ! -d "$DOTFILES" ]; then
  echo "Error: $DOTFILES not found. Clone the repo first:"
  echo "  git clone git@github.com:pwinston/dotfiles.git ~/dotfiles"
  exit 1
fi

# zsh: create stub files that source from dotfiles
create_zsh_stub() {
  local target="$1"
  local source_file="$2"
  local content="export DOTFILES=\"\$HOME/dotfiles\"
[ -f \"\$DOTFILES/$source_file\" ] && source \"\$DOTFILES/$source_file\""

  if [ -f "$target" ]; then
    echo "SKIP $target (already exists)"
  else
    echo "$content" > "$target"
    echo "CREATE $target"
  fi
}

create_zsh_stub "$HOME/.zshrc" "zsh/zshrc"
create_zsh_stub "$HOME/.zprofile" "zsh/zprofile"

# starship: symlink config
mkdir -p "$HOME/.config"
if [ -L "$HOME/.config/starship.toml" ] || [ -f "$HOME/.config/starship.toml" ]; then
  echo "SKIP ~/.config/starship.toml (already exists)"
else
  ln -s "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
  echo "LINK ~/.config/starship.toml"
fi

# wezterm: symlink config files
mkdir -p "$HOME/.config/wezterm"
for file in wezterm.lua projects-home.lua projects-work.lua; do
  target="$HOME/.config/wezterm/$file"
  if [ -L "$target" ] || [ -f "$target" ]; then
    echo "SKIP ~/.config/wezterm/$file (already exists)"
  else
    if [ -f "$DOTFILES/wezterm/$file" ]; then
      ln -s "$DOTFILES/wezterm/$file" "$target"
      echo "LINK ~/.config/wezterm/$file"
    fi
  fi
done

echo ""
echo "Done! You may also need to install:"
echo "  brew install starship pyenv direnv node@22"
echo "  # Install WezTerm from https://wezfurlong.org/wezterm/"
