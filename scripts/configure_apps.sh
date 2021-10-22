
function config_apps() {
  printf "Configuring apps...\n"
  while IFS=',' read -a $APP; do
    APP_NAME=${APP[0]}
    APP_CFG_PATH=${APP[1]}

    if [ "${APP_NAME}" != "zsh" ]; then
      printf " -> %s cfg: %s\n" "${APP_NAME}" "${APP_CFG_PATH}"
    fi
  done < ${DOTS_DIR}/configs/locations.txt
  job_done
}