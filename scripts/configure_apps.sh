
function config_apps() {
  copy_configs
  configure_applications
  if [ ${USE_BLUETOOTH} -eq 1 ]; then
    systemctl --user daemon-reload
    systemctl --user --now disable pulseaudio.{service,socket}
    systemctl --user mask pulseaudio
    systemctl --user --now enable pipewire-media-session.service
  fi
  configure_preferred_apps
  configure_keyboard

  apply_p1_stig
}

function configure_applications() {
  printf "Configuring apps... \n"
  configure_appgate

  if [ ${USE_CAC} -eq 1 ]; then
    configure_brave
  fi

  configure_docker
  configure_neovim
  configure_vscode
  job_done
}

function copy_configs() {
  printf "Copying app configs... \n"
  for APP in ${DOTS_DIR}/configs/*; do
    APP_NAME=$(basename ${APP})

    if [ "${APP_NAME}" != "zsh" ]; then
      printf " -> %s \n" "$APP_NAME"

      for CFG in $APP/*; do
        CFG_FILENAME=$(basename ${CFG})

        if [ "${CFG_FILENAME}" != "*" ]; then
          case "$APP_NAME" in
            "docker" | "sshd")
              APP_CFG_PATH=/etc/${APP_NAME}/${CFG_FILENAME}
            ;;

            "git" | "myrmidon")
              APP_CFG_PATH=$HOME/.$CFG_FILENAME
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
  sh -c "modutil -dbdir sql:$HOME/.pki/nssdb/ -list"
  sh -c "modutil -dbdir sql:$HOME/.pki/nssdb/ -add \"CAC Module\" -libfile $(whereis opensc-pkcs11.so) -force"
}

function configure_neovim() {
  new_line
  printf " -> neovim \n"
  printf "   -> Adding vim-plug... \n"
  sh -c 'curl -fsLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

function configure_docker() {
  new_line
  printf " -> docker \n"
  printf "   -> Adding $(whoami) to the docker group... \n"
  sh -c "sudo usermod -aG docker $(whoami)"
}

function configure_vscode() {
  new_line
  printf " -> vscode \n"
  while read -a EXT; do
    printf "   -> %s \n" "$EXT"
    code --install-extension "$EXT" &> /dev/null
  done < $SCRIPT_DIR/vscode/extensions.txt
}


function configure_preferred_apps() {
  printf "Setting app defaults... \n"
  printf " -> kitty as default x-terminal-emulator \n"
  sudo update-alternatives --quiet --set x-terminal-emulator $(which kitty)

  printf " -> brave-browser as default x-www-browser \n"
  sudo update-alternatives --quiet --set x-www-browser $(which brave-browser-stable)

  printf " -> neovim as default vi/vim \n"
  sudo update-alternatives --quiet --set vi $(which nvim)
  sudo update-alternatives --quiet --set vim $(which nvim)

  job_done
}

function configure_keyboard() {
  while true; do
    read -p "Set faster keyboard key repeat/shorter delay? [y/N]: " yn
    case "$yn" in
      [Yy]*)
        printf " -> Faster keyboard key repeat/shorter delay set! \n"
        gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20
        gsettings set org.gnome.desktop.peripherals.keyboard delay 280
        break
      ;;

      *)
        printf " -> No changes made. \n"
        break
      ;;
      esac
  done
  job_done

  configure_keyboard_shortcuts
}

function apply_p1_stig() {
  printf " -> Applying Platform One STIGs \n"
  sudo sh -c "curl -sL https://gist.githubusercontent.com/tonybutt/ebbe05b26acb5e5df5a171db8a91d7a4/raw/a4f9054f43baf1ab7036cea2839af54a06c9e096/apply-p1-stig-ubuntu.sh | bash"
  job_done
}

function configure_keyboard_shortcuts() {
  printf "Setting keyboard shortcuts... \n"

  job_done
}
