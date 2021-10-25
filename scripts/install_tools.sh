function install_tools() {
  printf "Installing tools \n"
  install_docker_compose
  install_helm
  install_k3d
  install_kind
  install_kustomize
  install_myrmidon
  job_done
}

function install_docker_compose() {
  if [ $(command_exists docker-compose) -eq 0 ]; then
    printf " -> Installing docker-compose... \n"
    sudo curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo sh -c "chmod +x /usr/local/bin/docker-compose"
  else
    printf " -> Found docker-compose, skipping... \n"
  fi
}

function install_helm() {
  if [ $(command_exists helm) -eq 0 ]; then
    printf " -> Installing helm... \n"
    curl "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" | bash
  else
    printf " -> Found helm, skipping... \n"
  fi
}

function install_k3d() {
  if [ $(command_exists k3d) -eq 0 ]; then
    printf " -> Installing k3d... \n"
    curl -s "https://raw.githubusercontent.com/rancher/k3d/main/install.sh" | bash

    printf " -> Adding k3d completions to your shell... \n"
    k3d completion zsh > $HOME/.oh-my-zsh/custom/plugins/zsh-completions/src/_k3d
  else
    printf " -> Found k3d, skipping... \n"
  fi
}

function install_kind() {
  if [ $(command_exists kind) -eq 0 ]; then
    printf " -> Installing kind... \n"
    pushd /tmp
      curl -sLo ./kind "https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64"
      sudo sh -c "chmod +x /tmp/kind"
      sudo sh -c "mv /tmp/kind /usr/local/bin/"
    popd
    printf " -> Adding kind completions to your shell... \n"
    kind completion zsh > $HOME/.oh-my-zsh/custom/plugins/zsh-completions/src/_kind
  else
    printf " -> Found kind, skipping... \n"
  fi
}

function install_kustomize() {
  if [ $(command_exists kustomize) -eq 0 ]; then
    printf " -> Installing kustomize... \n"
    pushd /tmp
    curl -sL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    if [ -f "/tmp/kustomize" ]; then
      sudo sh -c "mv /tmp/kustomize /usr/local/bin/"
    fi
    popd
    printf " -> Adding kustomize completions to your shell... \n"
    kustomize completion zsh > $HOME/.oh-my-zsh/custom/plugins/zsh-completions/src/_kustomize
  else
    printf " -> Found kustomize, skipping... \n"
  fi
}

function install_myrmidon() {
  if [ $(command_exists myrmidon.sh) -eq 0 ]; then
    printf " -> Installing myrmidon... \n"
    mkdir -p $HOME/scripts
    git clone -q https://github.com/moustacheful/myrmidon.git $HOME/scripts/myrmidon
  fi
}
