#!/usr/bin/env bash

ZSH_PLUGINS_DIR=$HOME/.oh-my-zsh/custom/plugins
ZSH_THEMES_DIR=$HOME/.oh-my-zsh/custom/themes

function setup_terminal() {
  install_oh_my_zsh
  clone_omz_plugins
  clone_omz_themes
  replace_zsh_configs
  add_terminal_fonts
}

function install_oh_my_zsh() {
  printf "Checking for Oh My Zsh... \n"
  if [ -d $HOME/.oh-my-zsh ]; then
    printf " -> Found Oh My Zsh, skipping..."
    success
  else
    printf " -> Oh My Zsh not found, installing..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1 &
    get_status
    if [ -f "$HOME/.zshrc" ]; then
      printf "Clearing stock oh-my-zsh config files..."
      mv $HOME/.zshrc $HOME/.zshrc.stock &
      get_status
      job_done
    fi
  fi
  job_done
}

function clone_omz_plugins() {
  printf "Checking for zsh plugins... \n"
  while IFS=',' read -a PLUGIN; do
    PLUGIN_NAME=${PLUGIN[0]}
    PLUGIN_URL=${PLUGIN[1]}

    if [ -d "${ZSH_PLUGINS_DIR}/${PLUGIN_NAME}" ]; then
      printf " -> Found %s, skipping..." "${PLUGIN_NAME}"
      success
    else
      printf " -> Cloning %s..." "${PLUGIN_NAME}"
      git clone -q ${PLUGIN_URL} ${ZSH_PLUGINS_DIR}/${PLUGIN_NAME} &> /dev/null &
      get_status
    fi
  done < $SCRIPT_DIR/ohmyzsh/plugins.txt
  job_done
}

function clone_omz_themes() {
  printf "Checking for zsh themes... \n"
  while IFS=',' read -a THEME; do
    THEME_NAME=${THEME[0]}
    THEME_URL=${THEME[1]}

    if [ -d "${ZSH_THEMES_DIR}/${THEME_NAME}" ]; then
      printf " -> Found %s, skipping..." "${THEME_NAME}"
      success
    else
      printf " -> Cloning %s..." "${THEME_NAME}"
      git clone -q --depth=1 ${THEME_URL} ${ZSH_THEMES_DIR}/${THEME_NAME} &> /dev/null &
      get_status
    fi
  done < $SCRIPT_DIR/ohmyzsh/themes.txt
  job_done
}

function replace_zsh_configs() {
  printf "Copying Trash Panda zsh configs... \n"
  for FILE in ${DOTS_DIR}/configs/zsh/*; do
    if [ -f ${HOME}/.$(basename ${FILE}) ]; then
      printf " -> Found .$(basename ${FILE}), skipping..."
      success
    else
      printf " -> Copying .%s..." $(basename ${FILE})
      cp "$FILE" "$HOME/.$(basename ${FILE})" &
      get_status
    fi
  done
  job_done

  printf "Updating shell..."
  sudo sh -c "chsh -s $(which zsh) $(whoami)" &
  get_status

  printf " -> You will see the changes when you open a new terminal \n"
  job_done
}

function add_terminal_fonts() {
  printf "Adding pretty terminal fonts... \n"
  local INSTALLED_FONTS=0
  mkdir -p $HOME/.fonts

  pushd /tmp
  printf " -> VictorMono NF \n"
  if [ -d ~/.fonts/VictorMono ]; then
    printf "   -> Found ~/.fonts/VictorMono, skipping..."
    sucess
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/VictorMono.zip
    unzip -qq VictorMono.zip -d ~/.fonts/VictorMono &
    get_status
    INSTALLED_FONTS=1
  fi

  printf " -> FiraCode NF \n"
  if [ -d ~/.fonts/FiraCode ]; then
    printf "   -> Found ~/.fonts/FiraCode, skipping..."
    success
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
    unzip -qq FiraCode.zip -d ~/.fonts/FiraCode &
    get_status
    INSTALLED_FONTS=1
  fi

  printf " -> Hasklug NF \n"
  if [ -d ~/.fonts/Hasklig ]; then
    printf "   -> Found ~/.fonts/Hasklug, skipping..."
    success
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hasklig.zip
    unzip -qq Hasklig.zip -d ~/.fonts/Hasklig &
    get_status
    INSTALLED_FONTS=1
  fi

  printf " -> JetBrains NF \n"
  if [ -d ~/.fonts/JetBrainsMono ]; then
    printf "   -> Found ~/.fonts/JetBrains, skipping..."
    success
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
    unzip -qq JetBrainsMono.zip -d ~/.fonts/JetBrainsMono &
    get_status
    INSTALLED_FONTS=1
  fi

  printf " -> Get more fonts at: https://www.nerdfonts.com/font-downloads \n"
  job_done

  if [ $INSTALLED_FONTS -eq 1 ]; then
    printf "Refreshing font-cache..."
    fc-cache -f &
    get_status
    printf "Cleaning up zip archives..."
    rm {VictorMono,FiraCode,Hasklig,JetBrainsMono}.zip
    success

    job_done
  fi

  popd
}