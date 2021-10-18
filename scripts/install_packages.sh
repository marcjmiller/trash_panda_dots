#!/usr/bin/env bash

function get_gpg() {
  sudo sh -c "curl -fsSLo /usr/share/keyrings/$1 $2"
}

function add_gpg_keys() {
  printf "Adding gpg keys...\n"

  # Brave https://brave.com/linux/#linux
  printf "Brave Browser\n"
  sudo sh -c "curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"

  # VS Code https://code.visualstudio.com/docs/setup/linux
  get_gpg 

}

function add_apt_sources() {
  printf "Installing packages...\n"
  # Brave
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list


}

function install_packages {
  add_gpg_keys
  add_apt_sources

  printf "Updating apt...\n"
  sudo sh -c "apt-get update"

  printf "Installing packages...\n"

  for package in ${PACKAGE_LIST[@]}
  do
    sudo sh -c "apt-get install -qq ${package}"
  done

}