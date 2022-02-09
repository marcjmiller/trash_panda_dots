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
      printf " -> %s already installed, skipping..." "${PACKAGE}"
      success
    else
      printf " -> Installing %s ... " "$PACKAGE"
      if [[ $PACKAGE =~ "virtualbox-ext-pack" ]]; then
        add_vbox_license_accept
      fi
      install_package "${PACKAGE}" &
      get_status
    fi
  done
  job_done
}

function add_vbox_license_accept {
  echo virtualbox-ext-pack virtualbox-ext-pack/license select true |sudo debconf-set-selections
}

function add_gpg_keys() { # TODO: Use a for-loop here to do them one-by-one with statuses for better output
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
      echo "$SRC" | sudo tee "$SOURCES_FOLDER/$FILE" > /dev/null &
      get_status
    fi
  done < $SCRIPT_DIR/apt/sources.txt

  printf " -> Fixing docker.list for %s..." "$CODENAME"
  sudo sh -c "sed -i 's/LSB_RELEASE_CS/${CODENAME}/g' /etc/apt/sources.list.d/docker.list" &> /dev/null &
  get_status
  job_done
}

function install_debs() {
  printf "Getting deb-file download links... \n"
  printf " -> Mattermost ... "
  MATTERMOST_DL_URL=$(curl -s https://api.github.com/repos/mattermost/desktop/releases/latest | jq '.assets[].browser_download_url' | grep amd64 | tr -d '"')
  printf "${MATTERMOST_DL_URL} \n"
  sed -i 's|MATTERMOST_DL_URL|'"${MATTERMOST_DL_URL}"'|g' $SCRIPT_DIR/apt/debs.txt

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
