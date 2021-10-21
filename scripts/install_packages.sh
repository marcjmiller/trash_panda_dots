#!/usr/bin/env bash

APT_SOURCES=$SCRIPT_DIR/apt/apt_sources.txt
SOURCES_FOLDER=/etc/apt/sources.list.d
REPO_URL=https://github.com/marcjmiller/trash_panda_dots.git

function add_gpg_keys() {
  printf "Adding gpg keys...\n"
  sudo sh -c "cp -u $DOTS_DIR/scripts/apt/gpg_keys/* /usr/share/keyrings/"
  job_done
}

function add_apt_sources() {
  printf "Adding apt sources...\n"
  while IFS=',' read -a SOURCE; do
    APP=${SOURCE[0]}
    SRC=${SOURCE[1]}
    FILE=${SOURCE[2]}

    if [ -f "$SOURCES_FOLDER/$FILE" ]; then
      printf " -> Found %s, skipping...\n" "$FILE"
    else
      printf " -> Adding source for %s...\n" "$APP"
      echo "$SRC" | sudo tee "$SOURCES_FOLDER/$FILE"
    fi
  done < $SCRIPT_DIR/apt/apt_sources.txt
  job_done
}

function install_apt {
  add_gpg_keys
  add_apt_sources
  apt_update

  printf "Installing packages with apt...\n"

  for PACKAGE in ${PACKAGE_LIST[@]}; do
    if [[ $(package_installed "$PACKAGE") -gt 0 ]]; then
      printf " -> %s already installed, skipping...\n" "${PACKAGE}"
    else
      printf " -> Installing %s ...\n" "$PACKAGE"
      install_package "${PACKAGE}"
    fi
  done
  job_done
}

function install_debs() {
  printf "Installing packages from .deb files...\n"
  download_debs

  printf " -> Installing debs...\n"
  for DEB in *.deb; do
    if [ -f "$DOTS_DIR/debs/$DEB" ]; then
      if [ $(package_installed "$PACKAGE") -eq 0 ]; then
        printf "   -> Installing %s deb...\n" "$DEB"
        install_package "$DOTS_DIR/tmp/debs/$DEB"
      fi
    else
      printf " -> No debs found to install...\n"
    fi
  done
  job_done
  popd
}

function download_debs() {
  printf " -> Grabbing files...\n"
  mkdir -p $DOTS_DIR/apt/debs
  pushd $DOTS_DIR/apt/debs
    while read -a DEB; do
      APP=${DEB[0]}
      CMD=${DEB[1]}
      URL=${DEB[2]}

      if [ $(command_exists "$CMD") ]; then
        printf "   -> %s already installed, skipping...\n" "$APP"
      else
        printf "   -> Downloading %s deb...\n" "$APP"
        curl -fSsLlO "${URL}"
      fi
    done < $SCRIPT_DIR/apt/debs.txt
    job_done
}
