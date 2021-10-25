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
    printf " -> Found Oh My Zsh, skipping... \n"
  else
    printf " -> Oh My Zsh not found, installing... \n"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ -f "$HOME/.zshrc" ]; then
      printf "Clearing stock oh-my-zsh config files... \n"
      mv $HOME/.zshrc $HOME/.zshrc.stock
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
      printf " -> Found %s, skipping... \n" "${PLUGIN_NAME}"
    else
      printf " -> Cloning %s... \n" "${PLUGIN_NAME}"
      git clone ${PLUGIN_URL} ${ZSH_PLUGINS_DIR}/${PLUGIN_NAME} &> /dev/null
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
      printf " -> Found %s, skipping... \n" "${THEME_NAME}"
    else
      printf " -> Cloning %s... \n" "${THEME_NAME}"
      git clone --depth=1 ${THEME_URL} ${ZSH_THEMES_DIR}/${THEME_NAME} &> /dev/null
    fi
  done < $SCRIPT_DIR/ohmyzsh/themes.txt
  job_done
}

function replace_zsh_configs() {
  printf "Copying Trash Panda zsh configs... \n"
  for FILE in ${DOTS_DIR}/configs/zsh/*; do
    if [ -f ${HOME}/.$(basename ${FILE}) ]; then
      printf " -> Found .$(basename ${FILE}), skipping... \n"
    else
      printf " -> Copying .%s...\n" $(basename ${FILE})
      cp "$FILE" "$HOME/.$(basename ${FILE})"
    fi
  done
  job_done

  printf "Updating shell... \n"
  sudo sh -c "chsh -s $(which zsh) $(whoami)"

  printf " -> You will see the changes when you open a new terminal \n"
  job_done
}

function add_terminal_fonts() {
  printf "Adding pretty terminal fonts... \n"
  mkdir -p $HOME/.fonts

  pushd /tmp
  printf " -> VictorMono NF \n"
  if [ -d ~/.fonts/VictorMono ]; then
    printf " -> Found ~/.fonts/VictorMono, skipping... \n"
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/VictorMono.zip
    unzip VictorMono.zip -d ~/.fonts/VictorMono
  fi

  printf " -> FiraCode NF \n"
  if [ -d ~/.fonts/FiraCode ]; then
    printf " -> Found ~/.fonts/FiraCode, skipping... \n"
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
    unzip FiraCode.zip -d ~/.fonts/FiraCode
  fi

  printf " -> Hasklug NF \n"
  if [ -d ~/.fonts/Hasklig ]; then
    printf " -> Found ~/.fonts/Hasklug, skipping... \n"
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hasklig.zip
    unzip Hasklig.zip -d ~/.fonts/Hasklig
  fi

  printf " -> JetBrains NF \n"
  if [ -d ~/.fonts/JetBrainsMono ]; then
    printf " -> Found ~/.fonts/JetBrains, skipping... \n"
  else
    curl -fsSLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
    unzip JetBrainsMono.zip -d ~/.fonts/JetBrainsMono
  fi

  printf " -> Get more at: https://www.nerdfonts.com/font-downloads \n"
  job_done

  printf "Refreshing font-cache... \n"
    fc-cache -fv
  job_done

  printf "Cleaning up zip archives... \n"
    rm {VictorMono,FiraCode,Hasklig,JetBrainsMono}.zip
  job_done
  popd
}