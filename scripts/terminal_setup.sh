#!/usr/bin/env bash

ZSH_PLUGINS_DIR=$HOME/.oh-my-zsh/custom/plugins
ZSH_THEMES_DIR=$HOME/.oh-my-zsh/custom/themes

function installOhMyZsh() {
  printf "Checking for Oh My Zsh...\n"
  if [ -d $HOME/.oh-my-zsh ]; then
    printf " -> Found Oh My Zsh, skipping...\n"
  else
    printf " -> Oh My Zsh not found, installing...\n"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
  job_done
}

function clonePlugins() {
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
  printf "Checking for zsh themes...\n"
  while IFS=',' read -a THEME; do
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
  if [ -f "$HOME/.zshrc" ]; then
    printf "Clearing stock oh-my-zsh config files...\n"
    mv $HOME/.zshrc $HOME/.zshrc.stock
    job_done
  fi

  printf "Copying Trash Panda zsh configs...\n"
  for FILE in ${DOTS_DIR}/*`; do
    if [ -f ${FILE} ]; then
      echo $FILE
    #   printf " -> Found $FILE, skipping...\n"
    # else
    #   printf " -> Copying %s...\n"
    #   cp "$DOTS_DIR/configs/zsh/$FILE" "$HOME/$FILE"
    fi
  done
  job_done

  printf "Updating shell...\n"
  sudo sh -c "chsh -s $(which zsh) $(whoami)"
  printf " -> You will see the changes when you open a new terminal\n"
  job_done
}
