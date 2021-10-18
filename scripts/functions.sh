#!/usr/bin/env bash

checkOs() {
  local VALID_RELEASES=( 20.04 21.04 )
  DIST=$(lsb_release -is)
  VERSION=$(lsb_release -rs)
  CODENAME=$(lsb_release -cs)

  printf "\nChecking OS and version...\n"

  if [[ ! "Ubuntu" =~ $DIST ]]; then
    printf "  Sorry, this script is only for Ubuntu\n"
    exit 1
  fi

  if [[ ! " ${VALID_RELEASES[*]} " =~ $VERSION ]]; then
    printf "  Sorry, only Ubuntu %s are supported\n"
    exit 1
  fi

  printf "  Found %s\n" "$(lsb_release -ds)"
}

function setup() {
  checkOs
  getElevatedPermissions
  queryLaptop
  queryBluetooth
}

function queryLaptop() {
  printf "\nAre you currently setting up a laptop? [yN]"
  old_stty_cfg=$(stty -g)
  stty raw -echo ; IS_LAPTOP=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
  if printf "$IS_LAPTOP" | grep -iq "^y" ;then
    printf "\n  Adding tlp to package list\n"
    PACKAGE_LIST=( ${PACKAGE_LIST[@]} tlp )
  else
    printf "\n  Skipping tlp setup\n"
  fi
}

function queryBluetooth() {
  printf "\nWill you be using a Bluetooth headset? [yN]"
  old_stty_cfg=$(stty -g)
  stty raw -echo ; USE_BLUETOOTH=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
  if printf "$USE_BLUETOOTH" | grep -iq "^y" ;then
    printf "\n  Adding pipewire-debian upstream ppa\n"
    sudo sh -c "add-apt-repository -y ppa:pipewire-debian/pipewire-upstream" 2>1 /dev/null
    printf "\n  Adding pipewire and dependencies to package list\n"
    PACKAGE_LIST=( ${PACKAGE_LIST[@]} pipewire gstreamer1.0-pipewire libspa-0.2-{bluetooth,jack} pipewire-audio-client-libraries )
  else
    printf "\n  Skipping tlp setup\n"
  fi
}

function getElevatedPermissions() {
  printf "\nRequesting elevated permissions to install software...\n"
  sudo -v
  while true; do
    sudo -n true;
    sleep 60;
    kill -0 "$$" || exit;
  done 2>/dev/null &
}

