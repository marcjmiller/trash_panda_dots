
function config_apps() {
  printf "Configuring apps...\n"
  copy_configs
  # configure_appgate # TODO: troubleshoot appgate config, it doesn't work under docker, the window hangs. VM maybe?
  configure_docker
  configure_preferred_apps
}

function copy_configs() {
  for APP in ${DOTS_DIR}/configs/*; do
    APP_NAME=$(basename ${APP})
    if [ "${APP_NAME}" != "zsh" ]; then
      printf " -> %s\n" "$APP_NAME"
      for CFG in $APP/*; do
        CFG_FILENAME=$(basename ${CFG})

        if [ "${CFG_FILENAME}" != "*" ]; then
          case $APP_NAME in
            "docker" | "sshd")
              APP_CFG_PATH=/etc/${APP_NAME}/${CFG_FILENAME}
              sudo sh -c "mkdir -p /etc/${APP_NAME}"
            ;;

            "git")
              APP_CFG_PATH=$HOME/.$CFG_FILENAME
            ;;

            *)
              APP_CFG_PATH=$HOME/.config/${APP_NAME}/${CFG_FILENAME}
            ;;
          esac

          if [ ! -f $APP_CFG_PATH ]; then
            printf "   -> Copying %s to %s\n" "${CFG_FILENAME}" "$(dirname ${APP_CFG_PATH})/.$"
          else
            printf "   -> Found %s (%s), moving to %s...\n" "${CFG_FILENAME}" "${APP_CFG_PATH}" "${CFG_FILENAME}.old"
            mv ${APP_CFG_PATH} ${APP_CFG_PATH}.old
          fi
          mkdir -p $(dirname ${APP_CFG_PATH})
          cp ${CFG} ${APP_CFG_PATH}
          if [ "$(basename $APP_CFG_PATH)" == ".gitconfig" ]; then
            read -p "Enter email for gitlab?  " USER_EMAIL
            sed -i "s/EMAIL_CHANGEME/${USER_EMAIL}/g" ${APP_CFG_PATH}
            read -p "Enter plaintext name for gitlab?  " USER_NAME
            sed -i "s/NAME_CHANGEME/${USER_NAME}/g" ${APP_CFG_PATH}
          fi
        fi
      done
    fi
  done
  job_done
}

function configure_appgate() {
  printf " -> appgate"
  appgate --url appgate://cnap-connect.code.cdl.af.mil/eyJwcm9maWxlTmFtZSI6IlBsYXRmb3JtMSAtIFNTTyIsInNwYSI6eyJtb2RlIjoiVENQIiwibmFtZSI6IlBsYXRmb3JtMS1TU08iLCJrZXkiOiJkNjJhMjQ3ODc0ZGIxY2IxOGZmYjFiNWI4OWQzZTM0ZTZkY2NjMzliOGY1MTI0NDBmN2Q2ZTFmYzlkNGMwMDM2In0sImNhRmluZ2VycHJpbnQiOiJkMzc5NmI4OTczNTU5N2E2OWNlNzVlMjQ0NjAzZmU3OGRlZDU0ZTZlYmJkYTQ1ZWM4NDE2OGRiNWUyNjBjN2FhIiwiaWRlbnRpdHlQcm92aWRlck5hbWUiOiJTU08gLSBQbGF0Zm9ybSAxIn0= --novalidate
}

function configure_docker() {
  printf "Adding $(whoami) to the docker group...\n"
  sh -c "sudo usermod -aG docker $(whoami)"
  job_done
}

function configure_preferred_apps() {
  printf "Setting app defaults...\n"
  printf " -> kitty\n"
  sudo update-alternatives --set x-terminal-emulator $(which kitty)
  job_done
}
