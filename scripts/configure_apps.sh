
function config_apps() {
  copy_configs
  # get_dod_certs # ****** WORK IN PROGRESS ******
  configure_applications
  if [ ${USE_BLUETOOTH} -eq 1 ]; then
    systemctl --user daemon-reload
    systemctl --user --now disable pulseaudio.{service,socket}
    systemctl --user mask pulseaudio
    sudo cp -vRa /usr/share/pipewire /etc/
    systemctl --user --now enable pipewire{,pulse}.{socket,service}
    systemctl --user --now enable wireplumber.service
  fi
  configure_preferred_apps
  configure_keyboard
  configure_mouse

  apply_p1_stig
}

function configure_applications() {
  printf "Configuring apps... \n"
  configure_appgate
  configure_brave
  configure_docker
  configure_keybinds
  configure_neovim
  configure_vscode
  configure_zoom
  job_done
}

function copy_configs() {
  declare -a SKIP_COPY
  SKIP_COPY=( dconf zsh )
  printf "Copying app configs... \n"
  for APP in ${DOTS_DIR}/configs/*; do
    APP_NAME=$(basename ${APP})

    if [[ ! ${SKIP_COPY[*]} =~ ${APP_NAME} ]]; then
      printf " -> %s \n" "$APP_NAME"

      for CFG in $APP/*; do
        CFG_FILENAME=$(basename ${CFG})

        if [ "${CFG_FILENAME}" != "*" ]; then
          case "$APP_NAME" in
            "docker")
              APP_CFG_PATH=/etc/${APP_NAME}/${CFG_FILENAME}
            ;;

            "sshd")
              APP_CFG_PATH=/etc/ssh/${CFG_FILENAME}
            ;;

            "git" | "myrmidon")
              APP_CFG_PATH=$HOME/.$CFG_FILENAME
            ;;

            "zoom")
              APP_CFG_PATH=$HOME/.config/$CFG_FILENAME
            ;;

            *)
              APP_CFG_PATH=$HOME/.config/${APP_NAME}/${CFG_FILENAME}
            ;;
          esac

          if [ ! -f $APP_CFG_PATH ]; then
            printf "   -> Copying %s to %s \n" "${CFG_FILENAME}" "$(dirname ${APP_CFG_PATH})"
          else
            printf "   -> Found %s (%s), moving to %s... \n" "${CFG_FILENAME}" "${APP_CFG_PATH}" "${CFG_FILENAME}.old"
            sudo mv ${APP_CFG_PATH} ${APP_CFG_PATH}.old
          fi

          if [[ "$APP_NAME" =~ "docker" || "$APP_NAME" =~ "sshd" ]]; then
            sudo sh -c "mkdir -p /etc/$APP_NAME"
            sudo cp ${CFG} ${APP_CFG_PATH}
          else
            mkdir -p $(dirname ${APP_CFG_PATH})
            cp ${CFG} ${APP_CFG_PATH}
          fi

          if [ "$(basename $APP_CFG_PATH)" == ".gitconfig" ]; then
            if [ "$GIT_EMAIL" = CHANGEME_EMAIL ]; then
              read -p "     -> Enter email for gitlab?  " GIT_EMAIL
            fi

            if [ "$GIT_USERNAME" = CHANGEME_USERNAME ]; then
              read -p "     -> Enter plaintext name for gitlab?  " GIT_USERNAME
            fi

            sed -i "s/EMAIL_CHANGEME/${GIT_EMAIL}/g" ${APP_CFG_PATH}
            sed -i "s/NAME_CHANGEME/${GIT_USERNAME}/g" ${APP_CFG_PATH}
          fi
        fi
      done
    fi
  done
  job_done
}

#  ****** WORK IN PROGRESS ******
# function get_dod_certs() {
#   # https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_DoD.zip
#   new_line
#   pushd /tmp
#     printf " -> grabbing DoD Certs "
#     curl -fsSLO https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/certificates_pkcs7_DoD.zip &
#     get_status
#     CERT_DIR=$(unzip certificates_pkcs7_DoD.zip | grep creating | awk '{ print $2 }')
#     pushd $CERT_DIR
#       PEMFILE=$(ls ./Certificates*pem*)
#       CERT_NAME="DoD Certs"
#       SYS_CERT_DIR="/usr/local/share/ca-certificates/extra"
#       printf "   -> adding DoD certs to system "
#       sudo sh -c "mkdir -p $SYS_CERT_DIR"
#       sudo sh -c "cp $PEMFILE $SYS_CERT_DIR"
#       sudo sh -c "update-ca-certificates" &
#       get_status
#     popd
#   popd
# }
#  ****** WORK IN PROGRESS ******

function configure_appgate() {
  new_line
  printf " -> appgate \n"
  appgate --url appgate://cnap-connect.code.cdl.af.mil/eyJwcm9maWxlTmFtZSI6IlBsYXRmb3JtMSAtIFNTTyIsInNwYSI6eyJtb2RlIjoiVENQIiwibmFtZSI6IlBsYXRmb3JtMS1TU08iLCJrZXkiOiJkNjJhMjQ3ODc0ZGIxY2IxOGZmYjFiNWI4OWQzZTM0ZTZkY2NjMzliOGY1MTI0NDBmN2Q2ZTFmYzlkNGMwMDM2In0sImNhRmluZ2VycHJpbnQiOiJkMzc5NmI4OTczNTU5N2E2OWNlNzVlMjQ0NjAzZmU3OGRlZDU0ZTZlYmJkYTQ1ZWM4NDE2OGRiNWUyNjBjN2FhIiwiaWRlbnRpdHlQcm92aWRlck5hbWUiOiJTU08gLSBQbGF0Zm9ybSAxIn0= --novalidate &> /dev/null &
}

function configure_brave() {
  new_line
  printf " -> brave-browser \n"
  sh -c "mkdir -p $HOME/.pki/nssdb"
  sh -c "certutil -d $HOME/.pki/nssdb -N --empty-password"
  # sh -c "modutil -dbdir sql:$HOME/.pki/nssdb/ -list"
  sh -c "modutil -dbdir sql:$HOME/.pki/nssdb/ -add \"CAC Module\" -libfile $(whereis opensc-pkcs11.so) -force"
}

function configure_keybinds() {
  new_line
  printf " -> dconf (keybindings) \n"
  printf "   -> Adding custom keybinds..."
  sed -i "s/CHANGEME_USER/$(whoami)/" ${CONFIGS_DIR}/dconf/keybindings.conf
  sh -c "dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < ${CONFIGS_DIR}/dconf/keybindings.conf" &
  get_status
}

function configure_neovim() {
  new_line
  printf " -> neovim \n"
  printf "   -> Adding vim-plug..."
  sh -c 'curl -fsLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' &
  get_status
}

function configure_docker() {
  new_line
  printf " -> docker \n"
  printf "   -> Adding $(whoami) to the docker group..."
  sh -c "sudo usermod -aG docker $(whoami)" &
  get_status
}

function configure_vscode() {
  new_line
  printf " -> vscode \n"
  while read -a EXT; do
    printf "   -> Installing %s ..." "$EXT"
    code --install-extension "$EXT" &> /dev/null &
    get_status
  done < $SCRIPT_DIR/vscode/extensions.txt
}

function configure_zoom() {
  new_line
  printf " -> zoom \n"
  printf "   -> enabling cloud switch "
  sed -i 's/enableCloudSwitch=false/enableCloudSwitch=true/' ~/.config/zoomus.conf
  job_done
}


function configure_preferred_apps() {
  printf "Setting app defaults... \n"
  printf " -> kitty as default x-terminal-emulator \n"
  sudo update-alternatives --quiet --set x-terminal-emulator $(which kitty)
  gsettings set org.gnome.desktop.default-applications.terminal exec $(which kitty)

  printf " -> brave-browser as default x-www-browser \n"
  sudo update-alternatives --quiet --set x-www-browser $(which brave-browser-stable)

  printf " -> neovim as default vi/vim \n"
  sudo update-alternatives --quiet --set vi $(which nvim)
  sudo update-alternatives --quiet --set vim $(which nvim)

  job_done
}

function configure_keyboard() {
  query "Set faster keyboard key repeat/shorter delay? [y/N]"
  if [[ $ANSWER =~ (y|Y) ]]; then
    printf " -> Faster keyboard key repeat/shorter delay set! \n"
    gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20
    gsettings set org.gnome.desktop.peripherals.keyboard delay 280
  else
    printf " -> No changes made. \n"
  fi
  job_done

  configure_keyboard_shortcuts
}

function configure_mouse() {
  query "Use natural scrolling? [y/N]"
  if [[ $ANSWER =~ (y|Y) ]]; then
    printf " -> Setting natural scrolling! \n"
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
  else
    printf " -> No changes made. \n"
  fi
  job_done
}

function apply_p1_stig() {
  printf "Applying Platform One STIGs \n"
  check_stigs
  apply_stigs
  job_done
}

function configure_keyboard_shortcuts() {
  printf "Setting keyboard shortcuts... \n"

  job_done
}
