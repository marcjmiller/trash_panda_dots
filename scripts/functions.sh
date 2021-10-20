#!/usr/bin/env bash

function setup() {
  checkOs
  getElevatedPermissions
  queryBluetooth
}

checkOs() {
  local VALID_RELEASES=( 20.04 21.04 )
  DIST="$(lsb_release -is)"
  VERSION="$(lsb_release -rs)"
  CODENAME="$(lsb_release -cs)"
  PRETTYNAME="$(lsb_release -ds)"

  newline
  printf "Checking OS and version...\n"

  if [[ ! "Ubuntu" =~ "$DIST" ]]; then
    printf "  Sorry, this script is only for Ubuntu\n"
    exit 1
  fi

  if [[ ! " ${VALID_RELEASES[*]} " =~ "$VERSION" ]]; then
    printf "  Sorry, Ubuntu %s not supported\n" "$VERSION"
    exit 1
  fi

  printf " -> Found %s\n" "$PRETTYNAME"
}

function queryBluetooth() {
  newline
  printf "Will you be using a Bluetooth headset? [y/N]"
  old_stty_cfg=$(stty -g)
  stty raw -echo ; USE_BLUETOOTH=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
  if printf "$USE_BLUETOOTH" | grep -iq "^y" ;then
    newline
    printf " -> Adding pipewire-debian upstream ppa\n"
    sudo sh -c "add-apt-repository -y ppa:pipewire-debian/pipewire-upstream" 2>1 /dev/null
    newline
    printf " -> Adding pipewire and dependencies to package list\n"
    PACKAGE_LIST=( ${PACKAGE_LIST[@]} pipewire gstreamer1.0-pipewire libspa-0.2-{bluetooth,jack} pipewire-audio-client-libraries )
  else
    newline
    printf " -> Skipping bluetooth headset setup\n"
  fi
  jobsDone
}

function getElevatedPermissions() {
  newline
  printf "Requesting elevated permissions to install software...\n"
  sudo -v
  jobsDone
  while true; do
    sudo -n true;
    sleep 60;
    kill -0 "$$" || exit;
  done 2>/dev/null &
}

function newline() {
  printf "\n"
}

function jobsDone() {
  printf " -> Done!\n"
}

function pushd {
  command pushd "$@" > /dev/null
}

function popd {
  command popd "$@" > /dev/null
}
