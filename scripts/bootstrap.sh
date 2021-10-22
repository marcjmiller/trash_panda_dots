#!/usr/bin/env bash

# Exit on any non-zero exit codes
# set -e

# URL for getting  the dotfiles
REPO_URL=https://github.com/marcjmiller/trash_panda_dots.git

# Paths
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTS_DIR=$HOME/.dotfiles

# Default packages to install
PACKAGE_LIST=()
readarray PACKAGE_LIST < $SCRIPT_DIR/apt/packages.txt

# Some starter Boolean vars, 0 = false, 1 = true
IS_LAPTOP=0   # Whether installing on a laptop or not

# Source all of our helper scripts
source $SCRIPT_DIR/functions.sh
source $SCRIPT_DIR/install_packages.sh
source $SCRIPT_DIR/terminal_setup.sh
source $SCRIPT_DIR/configure_apps.sh

function main {
  printf "Parsing script args...\n"
  for arg in "$@"; do
    case "$arg" in
      -v | --verbose)
        printf " -> Running script in verbose mode\n"
        set -x
        ;;

      -l | --laptop)
        printf " -> Laptop install: adding tlp to package list\n"
        IS_LAPTOP=1 IS_LAPTOP=1
        PACKAGE_LIST+=( tlp ) # ${PACKAGE_LIST[@]}
      ;;

      *)
        continue
      ;;
    esac
  done
  job_done

  ### General Setup ###
  setup
  get_repo
  install_apt
  install_debs

  ### Terminal Setup ###
  installOhMyZsh
  clonePlugins
  cloneThemes
  updateZshConfig

  ### Link configs ###
  config_apps

  ### Script end ###
  new_line
  printf "That's all folks!\n"
  new_line
}

main ${@}