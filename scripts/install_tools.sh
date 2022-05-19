function install_tools() {
  printf "Installing tools \n"
  # install_ansible
  install_docker_compose
  install_helm
  install_k3d
  install_kind
  install_kustomize
  install_myrmidon
  install_yq
  job_done
}

function install_ansible() {
  if [ $(command_exists ansible) -eq 0 ]; then
    printf " -> Installing ansible..."
    sudo sh -c "apt-add-repository ppa:ansible/ansible"

    install_package ansible &
    get_status
  else
    printf " -> Found docker-compose, skipping..."
    success
  fi
}

function install_docker_compose() {
  if [ $(command_exists docker-compose) -eq 0 ]; then
    printf " -> Installing docker-compose..."
    sudo curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo sh -c "chmod +x /usr/local/bin/docker-compose" &
    get_status
  else
    printf " -> Found docker-compose, skipping..."
    success
  fi
}

function install_helm() {
  if [ $(command_exists helm) -eq 0 ]; then
    printf " -> Installing helm..."
    curl -s "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" | bash &> /dev/null &
    get_status
  else
    printf " -> Found helm, skipping..."
    success
  fi
}

function install_k3d() {
  if [ $(command_exists k3d) -eq 0 ]; then
    printf " -> Installing k3d..."
    curl -s "https://raw.githubusercontent.com/rancher/k3d/main/install.sh" | bash &> /dev/null &
    get_status

    printf " -> Adding k3d completions to your shell..."
    k3d completion zsh > $HOME/.oh-my-zsh/custom/plugins/zsh-completions/src/_k3d &
    get_status
  else
    printf " -> Found k3d, skipping..."
    success
  fi
}

function install_kind() {
  if [ $(command_exists kind) -eq 0 ]; then
    printf " -> Installing kind..."
    pushd /tmp
      curl -sLo ./kind "https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64"
      sudo sh -c "chmod +x /tmp/kind"
      sudo sh -c "mv /tmp/kind /usr/local/bin/" &
      get_status
    popd
    printf " -> Adding kind completions to your shell..."
    kind completion zsh > $HOME/.oh-my-zsh/custom/plugins/zsh-completions/src/_kind &
    get_status
  else
    printf " -> Found kind, skipping..."
    success
  fi
}

function install_kustomize() {
  if [ $(command_exists kustomize) -eq 0 ]; then
    printf " -> Installing kustomize..."

    pushd /tmp
      curl -sL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash &> /dev/null &
      get_status

      if [ -f "/tmp/kustomize" ]; then
        sudo sh -c "mv /tmp/kustomize /usr/local/bin/"
      fi
    popd

    printf " -> Adding kustomize completions to your shell..."
    kustomize completion zsh > $HOME/.oh-my-zsh/custom/plugins/zsh-completions/src/_kustomize &
    get_status
  else
    printf " -> Found kustomize, skipping..."
    success
  fi
}

function install_myrmidon() {
  if [ -d $HOME/scripts/myrmidon ]; then
    printf " -> Found myrmidon, skipping..."
    success
  else
    printf " -> Installing myrmidon..."
    git clone -q https://github.com/moustacheful/myrmidon.git $HOME/scripts/myrmidon &
    get_status
  fi
}

function install_yq() {
  printf " -> Installing yq..."
  sudo sh -c "curl -flLso /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
  sudo sh -c "chmod a+x /usr/local/bin/yq" &
  get_status
}
