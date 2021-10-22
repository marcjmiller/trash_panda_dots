function install_tools() {
  printf "Installing tools\n"
  install_docker_compose
  install_helm
  install_k3d
  install_kind
  install_kustomize
  job_done
}

function install_docker_compose() {
  if [ $(command_exists docker-compose) -eq 0 ]; then
    printf " -> Installing docker-compose...\n"
    sudo curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  else
    printf " -> Found docker-compose, skipping...\n"
  fi
}

function install_helm() {
  if [ $(command_exists helm) -eq 0 ]; then
    printf " -> Installing helm...\n"
    curl -s "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3" | bash
  else
    printf " -> Found helm, skipping...\n"
  fi
}

function install_k3d() {
  if [ $(command_exists k3d) -eq 0 ]; then
    printf " -> Installing k3d...\n"
    curl -s "https://raw.githubusercontent.com/rancher/k3d/main/install.sh" | bash
  else
    printf " -> Found k3d, skipping...\n"
  fi
}

function install_kind() {
  if [ $(command_exists kind) -eq 0 ]; then
    printf " -> Installing kind...%s\n" "command_exists kind"
    pushd /tmp
      curl -s "https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64"
      sudo sh -c "chmod +x /tmp/kind"
      sudo sh -c "mv /tmp/kind /usr/local/bin/"
    popd
  else
    printf " -> Found kind, skipping...\n"
  fi
}

function install_kustomize() {
  if [ $(command_exists kustomize) -eq 0 ]; then
    printf " -> Installing kustomize..."
    pushd /tmp
    curl -sLo ./kind "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    if [ -f "/tmp/kustomize" ]; then
      sudo sh -c "mv /tmp/kustomize /usr/local/bin/"
    fi
    popd
  else
    printf " -> Found kustomize, skipping...\n"
  fi
}