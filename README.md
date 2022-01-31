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

### Script Options
When running the bootstrap script, the script accepts some options:

- `-v` or `--verbose`: Adds `set x` to echo every line of the file as it runs it (with variables replaced)
- `-l` or `--laptop`: Adds `tlp` to the list of packages to install, to increase battery life for laptops
- `-b` or `--bluetooth`: Replaces `pulseaudio` with `pipewire` to support HSP/HFP mode for bluetooth headsets
- `-s` or `--skip-apt`: Skips all apt steps (useful for me to test things outside of apt, since `apt update` can take a hot minute)

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
- Platform One STIGs
- python3
- rofi
- slack
- teams
- vs code
- zoom
- zsh
