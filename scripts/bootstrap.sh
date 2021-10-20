#!/usr/bin/env bash

# Exit on any non-zero exit codes
set -e

# Path to the script being executed
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Default packages to install
PACKAGE_LIST=()
readarray PACKAGE_LIST < $SCRIPT_DIR/packages.txt

# Some starter Boolean vars, 0 = false, 1 = true
IS_LAPTOP=0   # Whether installing on a laptop or not

# Source all of our helper scripts
source $SCRIPT_DIR/functions.sh
source $SCRIPT_DIR/install_packages.sh
source $SCRIPT_DIR/terminal_setup.sh

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
        IS_LAPTOP=1
        PACKAGE_LIST+=( tlp ) # ${PACKAGE_LIST[@]}
      ;;

      *)
        continue
      ;;
    esac
  done
  jobsDone

  ### General Setup ###
  setup
  install_apt
  install_debs

  ### Terminal Setup ###
  # installOhMyZsh
  # clonePlugins
  # updateZshConfig

  ### Link configs ###

  ### Script end ###
  newline
  printf "That's all folks!\n"
  newline
}

main ${@}