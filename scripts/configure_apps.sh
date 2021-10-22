
function config_apps() {
  printf "Configuring apps...\n"
  for APP in ${DOTS_DIR}/configs/*;do
    APP_NAME=$(basename $APP)
    if [ "${APP_NAME}" != "zsh" ]; then
      printf " -> %s\n" "$APP_NAME"
    fi
  done
}