#!/usr/bin/env bash

APT_SOURCES=$SCRIPT_DIR/apt/apt_sources.txt
SOURCES_FOLDER=/etc/apt/sources.list.d

function install_apt {
  add_gpg_keys
  add_apt_sources
  apt_update

  printf "Installing packages with apt... \n"

  for PACKAGE in ${PACKAGE_LIST[@]}; do
    if [[ $(package_installed ${PACKAGE}) -gt 0 ]]; then
      printf " -> %s already installed, skipping... \n" "${PACKAGE}"
    else
      printf " -> Installing %s ... " "$PACKAGE"
      install_package "${PACKAGE}" &
      get_status
    fi
  done
  job_done
}

function add_gpg_keys() {
  printf "Adding gpg keys..."
  sudo sh -c "cp -u $DOTS_DIR/scripts/apt/gpg_keys/* /usr/share/keyrings/" &
  get_status
  job_done
}

function add_apt_sources() {
  printf "Adding apt sources... \n"
  while IFS=',' read -a SOURCE; do
    APP=${SOURCE[0]}
    SRC=${SOURCE[1]}
    FILE=${SOURCE[2]}

    if [ -f "$SOURCES_FOLDER/$FILE" ]; then
      printf " -> Found %s, skipping..." "$FILE"
      success
    else
      printf " -> Adding source for %s in %s..." "$APP" "$SOURCES_FOLDER/$FILE"
      echo "$SRC" | sudo tee "$SOURCES_FOLDER/$FILE" &
      get_status
    fi
  done < $SCRIPT_DIR/apt/sources.txt

  printf " -> Fixing docker.list for %s..." "$CODENAME"
  sudo sh -c "sed -i 's/LSB_RELEASE_CS/${CODENAME}/g' /etc/apt/sources.list.d/docker.list" &
  get_status
  job_done
}

function install_debs() {
  printf "Installing packages from .deb files... \n"
  download_debs

  printf "Installing debs... \n"
  for DEB in `ls $HOME/.dotfiles/apt/debs/*.deb`; do
    if [ -f "$DEB" ]; then
      printf "   -> Installing %s..." "$(basename $DEB)"
      install_package $DEB &
      get_status
    else
      printf " -> No debs found to install..."
      success
    fi
  done
  job_done
  popd
}

function download_debs() {
  printf " -> Grabbing files... \n"
  mkdir -p $DOTS_DIR/apt/debs
  pushd $DOTS_DIR/apt/debs
    while IFS=',' read -a DEB; do
      APP=${DEB[0]}
      CMD=${DEB[1]}
      URL=${DEB[2]}

      if [ $(command_exists "$CMD") -gt 0 ]; then
        printf "   -> %s already installed, skipping..." "$APP"
        success
      else
        printf "   -> Downloading %s..." "$APP"
        curl -fSsLlO "${URL}" &
        get_status
      fi
    done < $SCRIPT_DIR/apt/debs.txt
    job_done
}
