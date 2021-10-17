#!/usr/bin/env bash

# Exit on any non-zero exit codes
set -e

# Default packages to install
PACKAGE_LIST=(
  apt-transport-https
  brave-browser
  ca-certificates
  code
  curl
  fzf
  git
  gnupg
  kitty
  mattermost-desktop
  maven
  neovim
  nodejs
  npm
  python3
  slack
  software-properties-common
  wget
  zsh
  )

# Path to the script being executed
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Source all of our helper scripts
source $SCRIPT_DIR/functions.sh
source $SCRIPT_DIR/terminal_setup.sh

function main {
  case "${1}" in
    -v | --verbose)
      printf "Running script in verbose mode\n"
      set -x
      ;;

    *)
      printf "Running script in regular mode\n"
    ;;
  esac

  # General machine Setup
  setup
  installPackages

  # Terminal Setup
  installOhMyZsh
  clonePlugins
  updateZshConfig

  # Link configs
}

main ${@}