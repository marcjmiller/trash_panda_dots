# Env Setup (Trash Panda Style)

## Pipewire (Optional, better Bluetooth)
```
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream  
sudo apt install -y pipewire gstreamer1.0-pipewire libspa-0.2-{bluetooth,jack} pipewire-audio-client-libraries   

systemctl --user daemon-reload   
systemctl --user --now disable pulseaudio.{service,socket}  
systemctl --user mask pulseaudio  
systemctl --user --now enable pipewire-media-session.service  

sudo reboot  

pactl info | grep "Server Name"  

Server Name: PulseAudio (on PipeWire 0.3.37)
``` 

## TLP (optional, Laptop Battery tool)
```
sudo apt install -y tlp  
```

## Brave Browser (Optional)
```
sudo apt install apt-transport-https curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install -y brave-browser
```

## Build Tools
```
sudo apt install -y fzf git neovim pipenv zsh python3 nodejs npm
```

## OhMyZsh
```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### OhMyZsh Auto-Suggestions/Completions plugins
```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
```

## Install Nerd Font(s)
```
www.nerdfonts.com and pick a font that tickles your fancy, save it in ~/.fonts/<font-name>
```

## Install Powerlevel10k (optional)
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k  

# Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc
```

## Clone dotfiles repo
```
git clone https://github.com/marcjmiller/trash_panda_dots
```

## Install VS Code (Alternatively use the [deb](https://code.visualstudio.com/Download) which adds the repo as well)
```
echo "deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list  

eval $(apt-config shell APT_TRUSTED_PARTS Dir::Etc::trustedparts/d)  

echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.7 (GNU/Linux)

mQENBFYxWIwBCADAKoZhZlJxGNGWzqV+1OG1xiQeoowKhssGAKvd+buXCGISZJwT
LXZqIcIiLP7pqdcZWtE9bSc7yBY2MalDp9Liu0KekywQ6VVX1T72NPf5Ev6x6DLV
7aVWsCzUAF+eb7DC9fPuFLEdxmOEYoPjzrQ7cCnSV4JQxAqhU4T6OjbvRazGl3ag
OeizPXmRljMtUUttHQZnRhtlzkmwIrUivbfFPD+fEoHJ1+uIdfOzZX8/oKHKLe2j
H632kvsNzJFlROVvGLYAk2WRcLu+RjjggixhwiB+Mu/A8Tf4V6b+YppS44q8EvVr
M+QvY7LNSOffSO6Slsy9oisGTdfE39nC7pVRABEBAAG0N01pY3Jvc29mdCAoUmVs
ZWFzZSBzaWduaW5nKSA8Z3Bnc2VjdXJpdHlAbWljcm9zb2Z0LmNvbT6JATUEEwEC
AB8FAlYxWIwCGwMGCwkIBwMCBBUCCAMDFgIBAh4BAheAAAoJEOs+lK2+EinPGpsH
/32vKy29Hg51H9dfFJMx0/a/F+5vKeCeVqimvyTM04C+XENNuSbYZ3eRPHGHFLqe
MNGxsfb7C7ZxEeW7J/vSzRgHxm7ZvESisUYRFq2sgkJ+HFERNrqfci45bdhmrUsy
7SWw9ybxdFOkuQoyKD3tBmiGfONQMlBaOMWdAsic965rvJsd5zYaZZFI1UwTkFXV
KJt3bp3Ngn1vEYXwijGTa+FXz6GLHueJwF0I7ug34DgUkAFvAs8Hacr2DRYxL5RJ
XdNgj4Jd2/g6T9InmWT0hASljur+dJnzNiNCkbn9KbX7J/qK1IbR8y560yRmFsU+
NdCFTW7wY0Fb1fWJ+/KTsC4=
=J6gs
-----END PGP PUBLIC KEY BLOCK-----
" | gpg --dearmor > $APT_TRUSTED_PARTS/microsoft.gpg  

sudo apt install -y code

```

## Kubernetes tools (Docker, Kubectl, K3d, Helm, Kustomize)
```
sudo apt install -y gnupg lsb-release apt-transport-https ca-certificates  

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg  

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null  

sudo apt install -y docker-ce docker-ce-cli containerd.io  

sudo usermod -aG docker $(whoami)

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg  

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list  

sudo apt update  

sudo apt install -y kubectl  

curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash  

k3d completion zsh > $ZSH_CUSTOM/plugins/k3d.zsh  

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash  

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash  

sudo mv $HOME/kustomize /usr/local/bin  
```

## Apps install from .deb (Slack, Mattermost, AppGate SDP)
```
sudo apt install -f *.deb  

```

## Configure AppGate
```
Profile Link: appgate://cnap-connect.code.cdl.af.mil/eyJwcm9maWxlTmFtZSI6IlBsYXRmb3JtMSAtIFNTTyIsInNwYSI6eyJtb2RlIjoiVENQIiwibmFtZSI6IlBsYXRmb3JtMS1TU08iLCJrZXkiOiJkNjJhMjQ3ODc0ZGIxY2IxOGZmYjFiNWI4OWQzZTM0ZTZkY2NjMzliOGY1MTI0NDBmN2Q2ZTFmYzlkNGMwMDM2In0sImNhRmluZ2VycHJpbnQiOiJkMzc5NmI4OTczNTU5N2E2OWNlNzVlMjQ0NjAzZmU3OGRlZDU0ZTZlYmJkYTQ1ZWM4NDE2OGRiNWUyNjBjN2FhIiwiaWRlbnRpdHlQcm92aWRlck5hbWUiOiJTU08gLSBQbGF0Zm9ybSAxIn0=
```