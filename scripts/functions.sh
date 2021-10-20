#!/usr/bin/env bash

function setup() {
  check_os
  get_elevated_permissions
  query_bluetooth
}

check_os() {
  local VALID_RELEASES=( 20.04 21.04 )
  DIST="$(lsb_release -is)"
  VERSION="$(lsb_release -rs)"
  CODENAME="$(lsb_release -cs)"
  PRETTYNAME="$(lsb_release -ds)"

  new_line
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

function get_repo() {
  new_line
  printf "Checking for git...\n"
  if [  $(package_installed git) -gt 0 ]; then
    printf " -> Found git!"
  else
    printf " -> Git not found, installing git...\n"
    apt_update
    install_package git
  fi
  job_done

  new_line
  printf "Checking for dotfiles repository...\n"
  if [ -d "${DOTS_DIR}" ]; then
    printf " -> Dotfiles repository found skipping clone\n"
    new_line
    printf "Execute git pull? [y/N]\n"
    old_stty_cfg=$(stty -g)
    stty raw -echo ; GIT_PULL=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
    if printf "$GIT_PULL" | grep -iq "^y" ;then
      pushd $DOTS_DIR
      git pull
    fi
  else
    printf " -> No dotfiles repository found, cloning...\n"
    git clone ${REPO_URL} ${DOTS_DIR}
    pushd $DOTS_DIR
  fi
  job_done
}

function query_bluetooth() {
  new_line
  printf "Will you be using a Bluetooth headset? [y/N]"
  old_stty_cfg=$(stty -g)
  stty raw -echo ; USE_BLUETOOTH=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
  if printf "$USE_BLUETOOTH" | grep -iq "^y" ;then
    new_line
    printf " -> Adding pipewire-debian upstream ppa\n"
    sudo sh -c "add-apt-repository -y ppa:pipewire-debian/pipewire-upstream" > /dev/null
    new_line
    printf " -> Adding pipewire and dependencies to package list\n"
    PACKAGE_LIST=( ${PACKAGE_LIST[@]} pipewire gstreamer1.0-pipewire libspa-0.2-{bluetooth,jack} pipewire-audio-client-libraries )
  else
    new_line
    printf " -> Skipping bluetooth headset setup\n"
  fi
  job_done
}

function get_elevated_permissions() {
  new_line
  printf "Requesting elevated permissions to install software...\n"
  sudo -v
  job_done
  while true; do
    sudo -n true;
    sleep 60;
    kill -0 "$$" || exit;
  done 2>/dev/null &
}

function command_exists() {
  command -v "$@" >/dev/null 2>&1 | wc -l
}

function install_package() {
  sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -qq ${1}" < /dev/null > /dev/null
}

function apt_update() {
  sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get update -qq"
}

function package_installed() {
  dpkg-query -W -f='${Status}\n' $@ 2>&1| grep -c "ok installed"
  return 0
}

function new_line() {
  printf "\n"
}

function job_done() {
  printf " -> Done!\n"
}

function pushd {
  command pushd "$@" > /dev/null
}

function popd {
  command popd "$@" > /dev/null
}