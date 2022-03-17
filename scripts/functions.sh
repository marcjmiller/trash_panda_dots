#!/usr/bin/env bash

declare ANSWER

function setup() {
  check_os
  get_elevated_permissions
  query_langs
  query_bluetooth
}

check_os() {
  local VALID_RELEASES=( 20.04 21.04 21.10 )
  DIST="$(lsb_release -is)"
  VERSION="$(lsb_release -rs)"
  CODENAME="$(lsb_release -cs)"
  PRETTYNAME="$(lsb_release -ds)"

  printf "Checking OS and version... \n"

  if [[ ! "Ubuntu" =~ "$DIST" ]]; then
    printf "  Sorry, this script is only for Ubuntu \n"
    exit 1
  fi

  if [[ ! " ${VALID_RELEASES[*]} " =~ "$VERSION" ]]; then
    printf "  Sorry, Ubuntu %s not supported \n" "$VERSION"
    exit 1
  fi

  printf " -> Found %s \n\n" "$PRETTYNAME"
}

function get_repo() {
  printf "Checking for git... \n"
  if [  $(package_installed git) -gt 0 ]; then
    printf " -> Found git! \n"
  else
    printf " -> Git not found, installing git... \n"
    apt_update
    install_package git
  fi
  job_done

  printf "Checking for dotfiles repository... \n"
  if [ -d "${DOTS_DIR}" ]; then
    printf " -> Dotfiles repository found skipping clone \n"
    query " -> Execute git pull? [y/N]  "
    pushd $DOTS_DIR

    if [[ $ANSWER =~ (y|Y) ]]; then
      git pull
    fi
  else
    printf " -> No dotfiles repository found, cloning... \n"
    git clone -q ${REPO_URL} ${DOTS_DIR}
    pushd $DOTS_DIR
  fi
  job_done
}

function query_bluetooth() {
  if [ -z ${USE_BLUETOOTH+x} ]; then
    query "Will you be using a Bluetooth headset? [y/N]"
    if [[ $ANSWER =~ (y|Y) ]]; then
      new_line
      printf " -> Adding pipewire-debian upstream ppa \n"
      sudo sh -c "add-apt-repository -y ppa:pipewire-debian/pipewire-upstream" > /dev/null
      new_line
      printf " -> Adding wireplumber upstream ppa \n"
      sudo sh -c "add-apt-repository -y ppa:pipewire-debian/wireplumber-upstream" > /dev/null
      new_line
      printf " -> Adding pipewire and dependencies to package list \n"
      PACKAGE_LIST=( ${PACKAGE_LIST[@]} libfdk-aac2 libldacbt-{abr,enc}2 libopenaptx0 gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,locales,tests}} pipewire-doc wireplumber{,-doc} gir1.2-wp-0.4 libwireplumber-0.4-{0,dev} )
      USE_BLUETOOTH=1
    else
      new_line
      printf " -> Skipping bluetooth headset setup  \n"
    fi
    job_done
  fi
}

function get_elevated_permissions() {
  printf "Script requires elevated permissions to install software... \n"
  printf " -> Requesting sudo to install software... \n"
  sudo -v
  job_done
  while true; do
    sudo -n true;
    sleep 60;
    kill -0 "$$" || exit;
  done 2>/dev/null &
}

function query() {
  ANSWER="n"
  echo -e $@
  old_stty_cfg=$(stty -g)
  stty raw -echo ; ANSWER=$(head -c 1) ; stty $old_stty_cfg
}

function query_langs() {
  local -a LANGS=( golang node python rust )
  for DEV_LANG in "${LANGS[@]}"; do
    query "Will you be developing in $DEV_LANG? [y/N]"
    if [[ $ANSWER =~ (y|Y) ]]; then
      printf " -> Adding $DEV_LANG \n"
      add_lang $DEV_LANG
    fi
  done
}

function add_lang() {
  DEV_LANG=$1

  case "$DEV_LANG" in
    "golang")
      PACKAGE_LIST+=( golang )
    ;;

    "node")
      PACKAGE_LIST+=( npm )
      sh -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash"
      sh -c "nvm install 16 && nvm use 16"
    ;;

    "python")
      PACKAGE_LIST+=( pipenv python3 python3-pip )
    ;;

    "rust")
      PACKAGE_LIST+=( rust-all )
    ;;

    *)
      continue
    ;;
  esac
}

function command_exists() {
  command -v "$@" | wc -l
}

function install_package() {
  sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get -qq install ${1}" < /dev/null > /dev/null
}

function apt_update() {
  printf " -> Updating apt repositories... "
  sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get -qq update" &
  get_status

  job_done
}

function package_installed() {
  dpkg-query -W -f='${Status}\n' $@ 2>&1| grep -c "ok installed"
  return 0
}

function new_line() {
  printf "\n"
}

function job_done() {
  printf "Done! \n\n"
}

function get_status() {
  wait $!

  if [ $? -eq 0 ]; then
    success
  else
    fail
  fi
}

function success() {
  printf " ✓ \n"
}

function fail() {
  printf " ✗ \n"
}

function pushd {
  command pushd "$@" > /dev/null
}

function popd {
  command popd "$@" > /dev/null
}
