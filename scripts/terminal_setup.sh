#!/usr/bin/env bash

function installOhMyZsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

function clonePlugins() {
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
}

function updateZshConfig() {
  printf "Clearing default zsh config files...\n"
  sh -c "rm -rf $HOME/.zsh*"
  ln -s "$SCRIPT_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  ln -s "$SCRIPT_DIR/config/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
  ln -s "$SCRIPT_DIR/config/zsh/.zsh_exports" "$HOME/.zsh_exports"
  ln -s "$SCRIPT_DIR/config/zsh/.zsh_func" "$HOME/.zsh_func"
  printf "Sourcing new zsh config files...\n"
  sudo sh -c "chsh /bin/zsh $(whoami)"
  source "$HOME/.zshrc"
}
