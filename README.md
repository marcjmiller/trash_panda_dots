# Trash Panda Dotfiles

### About this Repository
The purpose of this repo is to quickly configure a new machine for use by DevSecOps Engineers. For a list of packages installed by this script, see `./scripts/packages.txt` which is read into an array during script execution.

### Prerequisites
- System must be running Ubuntu 20.04 or 21.04 (or some variant of those releases)

### Installation
1. (Optional) Set environment variables for `GIT_EMAIL` and `GIT_USERNAME`. If not set, the script will ask for them
2. Clone the repository  directory
```git clone https://github.com/marcjmiller/trash_panda_dots $HOME/.dotfiles```
3. Change to the directory
```cd $HOME/.dotfiles```
4. Run
```./scripts/bootstrap.sh```

### What this repo sets up for you
- appgate sdp
- brave-browser
- discord
- docker
- fzf (CLI fuzzy finder)
- kubectl
- kustomize
- git
- helm
- mattermost-desktop
- maven
- neovim (vi/vim alternative)
- nodejs
- npm
- ohmyzsh (and plugins)
- python3
- rofi
- slack
- teams
- vs code
- zoom
- zsh
