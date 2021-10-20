#!/usr/bin/env bash

ZSH_PLUGINS_DIR=${HOME}/.oh-my-zsh/custom/plugins
ZSH_THEMES_DIR=${HOME}/.oh-my-zsh/custom/themes

function installOhMyZsh() {
  # If you have issues, delete the $HOME/.oh-my-zsh directory and re-run the script below, then re-run the bootstrap script
  new_line
  printf "Checking for Oh My Zsh...\n"
  if [ -d ${HOME}/.oh-my-zsh ]; then
    printf " -> Found Oh My Zsh, skipping...\n"
  else
    printf " -> Oh My Zsh not found, installing...\n"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  job_done
}

function clonePlugins() {
  new_line
  printf "Checking for zsh plugins...\n"
  while IFS=',' read -a PLUGIN; do
    PLUGIN_NAME=${PLUGIN[0]}
    PLUGIN_URL=${PLUGIN[1]}

    if [ -d "${ZSH_PLUGINS_DIR}/${PLUGIN_NAME}" ]; then
      printf " -> Found %s, skipping...\n" "${PLUGIN_NAME}"
    else
      printf " -> Cloning %s...\n" "${PLUGIN_NAME}"
      git clone ${PLUGIN_URL} ${ZSH_PLUGINS_DIR}/${PLUGIN_NAME} &> /dev/null
    fi
  done < $SCRIPT_DIR/ohmyzsh/plugins.txt
  job_done
}

function cloneThemes() {
  new_line
  printf "Checking for zsh themes...\n"
  while IFS= read -a THEME; do
    THEME_NAME=${THEME[0]}
    THEME_URL=${THEME[1]}

    if [ -d "${ZSH_THEMES_DIR}/${THEME_NAME}" ]; then
      printf " -> Found %s, skipping...\n" "${THEME_NAME}"
    else
      printf " -> Cloning %s...\n" "${THEME_NAME}"
      git clone --depth=1 ${THEME_URL} ${ZSH_THEMES_DIR}/${THEME_NAME} &> /dev/null
    fi
  done < $SCRIPT_DIR/ohmyzsh/themes.txt
  job_done
}

function updateZshConfig() {
  new_line
  printf "Clearing current zsh config files...\n"
  sh -c "rm -rf ${HOME}/.zsh*"
  job_done

  new_line
  printf "Copying zsh configs...\n"
  cp "$DOTS_DIR/configs/zsh/.zshrc" "${HOME}/.zshrc"
  cp "$DOTS_DIR/configs/zsh/.zsh_aliases" "${HOME}/.zsh_aliases"
  cp "$DOTS_DIR/configs/zsh/.zsh_exports" "${HOME}/.zsh_exports"
  cp "$DOTS_DIR/configs/zsh/.zsh_func" "${HOME}/.zsh_func"
  job_done

  new_line
  printf "Updating shell...\n"
  sudo sh -c "chsh -s $(which zsh) $(whoami)"
  job_done

  # new_line
  # printf "Starting zsh...\n"
  # zsh
  # job_done
  # source "${HOME}/.zshrc"
}
