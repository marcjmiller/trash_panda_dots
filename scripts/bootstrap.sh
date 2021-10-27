#!/usr/bin/env bash

# Exit on any non-zero exit codes
# set -e

# URL for getting  the dotfiles
REPO_URL=https://github.com/marcjmiller/trash_panda_dots.git

# Git user info (optional)
GIT_EMAIL=${GIT_EMAIL:-CHANGEME_EMAIL}
GIT_USERNAME=${GIT_USERNAME:-CHANGEME_USERNAME}

# Paths
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOTS_DIR=$HOME/.dotfiles

# Default packages to install
PACKAGE_LIST=()
readarray PACKAGE_LIST < $SCRIPT_DIR/apt/packages.txt

# Some starter Boolean vars, 0 = false, 1 = true
IS_LAPTOP=${IS_LAPTOP:-0}           ! -z# Whether installing on a laptop or not
USE_BLUETOOTH=${USE_BLUETOOTH:-0}   # Whether setting up for Bluetooth with pipewire

# Source all of our helper scripts
source $SCRIPT_DIR/functions.sh
source $SCRIPT_DIR/install_packages.sh
source $SCRIPT_DIR/install_tools.sh
source $SCRIPT_DIR/terminal_setup.sh
source $SCRIPT_DIR/configure_apps.sh

function main {
  printf "Parsing script args... \n"
  for arg in "$@"; do
    case "$arg" in
      -v | --verbose)
        printf " -> Running script in verbose mode \n"
        set -x
        ;;

      -l | --laptop)
        printf " -> Laptop install: adding tlp to package list \n"
        IS_LAPTOP=1
        PACKAGE_LIST+=( tlp )
      ;;

      -b | --bluetooth)
        printf " -> Setting up pipewire for Bluetooth \n"
        USE_BLUETOOTH=1
        PACKAGE_LIST+=( pipewire gstreamer1.0-pipewire libspa-0.2-{bluetooth,jack} pipewire-audio-client-libraries )
      ;;

      -c | --cac)
        printf " -> Setting up CAC tools \n"
        USE_CAC=1
        PACKAGE_LIST+=( libnss3-tools libpcsclite1 pcscd pcsc-tools libpam-pkcs11 seahorse )
      ;;

      -s | --skip-apt)
        printf " -> Skipping apt functions \n"
        SKIP_APT=1
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

  if [ -z "${SKIP_APT+x}" ]; then
    install_apt
    install_debs
  fi


  ### Terminal Setup ###
  setup_terminal
  install_tools

  ### Configure Apps ###
  config_apps

  ### Script End ###
  new_line
  printf "That's all folks! \n"
  new_line
}

main ${@}