#!/usr/bin/env bash

# Populate GPG_KEYS and APT_SOURCES arrays from text files
# declare -a GPG_KEYS
# readarray GPG_KEYS < $SCRIPT_DIR/gpg_keys.txt
# while IFS= read -r line; do
#   GPG_KEYS+=( "$line" )
# done < $SCRIPT_DIR/gpg_keys.txt

APT_SOURCES_ARR=()
readarray APT_SOURCES < $SCRIPT_DIR/apt_sources.txt

# function get_gpg() {
#   APP=${LINE[0]}
#   FILE=${LINE[1]}
#   LOC=${LINE[2]}
#   printf "Adding GPG key for: %s...\n" $APP
#   sudo curl -fsSLo "/usr/share/keyrings/${FILE}" "${LOC}"
# }

# function add_gpg_keys() {
#   newline
#   printf "Adding gpg keys...\n"
#   while read -a LINE; do
#     get_gpg $LINE[@]
#     # printf "Adding key for %s...\n" ${LINE[0]}
#     # printf "%s %s\n" ${LINE[1]} ${LINE[2]}
#   done < $SCRIPT_DIR/gpg_keys.txt
# }

function add_apt_sources() {
  newline
  printf "Adding apt sources...\n"
  for source in ${APT_SOURCES[@]}; do
    printf " -> Adding apt source '%s'...\n" "$source"
  done
}

function install_packages {
  # TODO: Implement this function to copy keys from gpg_keys > /usr/share/keyrings/
  # add_gpg_keys
  add_apt_sources

  newline
  printf "Updating apt...\n"
  echo 'sudo sh -c "apt-get update"' # uncomment this

  newline
  printf "Installing packages...\n"

  for package in ${PACKAGE_LIST[@]}
  do
    printf "Installing %s with apt...\n" $package
    # sudo sh -c "apt-get install -qq ${package}"
  done
}
