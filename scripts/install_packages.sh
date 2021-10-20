#!/usr/bin/env bash

APT_SOURCES=$SCRIPT_DIR/apt_sources.txt
SOURCES_FOLDER=/etc/apt/sources.list.d

function add_gpg_keys() {

  newline
  printf "Adding gpg keys...\n"
  sudo sh -c "cp -u $SCRIPT_DIR/gpg_keys/* /usr/share/keyrings/"
  jobsDone
}

function add_apt_sources() {
  newline
  printf "Adding apt sources...\n"
  while IFS=',' read -a SOURCE; do
    APP=${SOURCE[0]}
    SRC=${SOURCE[1]}
    FILE=${SOURCE[2]}

    if [ -f "$SOURCES_FOLDER/$FILE" ]; then
      printf " -> Found %s, skipping...\n" "$FILE"
    else
      printf " -> Adding source for %s...\n" "$APP"
      echo "$SRC" > "$SOURCES_FOLDER/$FILE"
    fi
  done < $SCRIPT_DIR/apt_sources.txt
  jobsDone
}

function install_apt {
  add_gpg_keys
  add_apt_sources

  newline
  printf "Updating apt...\n"
  sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get update -qq"
  jobsDone

  newline
  printf "Installing packages with apt...\n"

  for PACKAGE in ${PACKAGE_LIST[@]}
  do
    PKG_INSTALLED=$(dpkg-query -W -f='${db:Status-Status}' $PACKAGE 2>&1| grep -c "installed"; return 0)
    if [ $PKG_INSTALLED -ge 1 ]; then
      printf " -> %s already installed, skipping...\n" "${PACKAGE}"
    else
      printf " -> Installing %s ...\n" "$PACKAGE"
      sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -qq ${PACKAGE}" < /dev/null > /dev/null
    fi
  done

  function install_debs() {
    newline
    printf "Installing packages from .deb files...\n"
    mkdir -p /tmp/debs

    pushd /tmp/debs
      printf " -> Grabbing files...\n"
      while read -a DEB; do
        APP=${DEB[0]}
        URL=${DEB[1]}

        printf "   -> Downloading %s deb...\n" "$APP"
        curl -fSsLlO "${URL}"
      done < $SCRIPT_DIR/debs.txt
      jobsDone
      newline

      printf " -> Installing debs...\n"
      for DEB in *.deb; do
        sudo sh -c "DEBIAN_FRONTEND=noninteractive apt-get install -qq /tmp/debs/${DEB}" < /dev/null > /dev/null
      done
      jobsDone
    popd
  }
}
