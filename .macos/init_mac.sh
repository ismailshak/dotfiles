#!/usr/bin/env bash

# ~/.macos — https://github.com/kentcdodds/dotfiles/blob/master/.macos
# Modified by Ismail Elshakankiry
# Run without downloading:
# curl https://raw.githubusercontent.com/ismailshak/dotfiles/main/macos/.macos | bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Hello $(whoami)! Let's get you set up."

echo "mkdir -p ${HOME}/code"
mkdir -p "${HOME}/code"

if [[ `xcode-select -p` != "/Applications/Xcode.app/Contents/Developer" && `xcode-select -p` != "/Applications/Xcode-beta.app/Contents/Developer" ]]; then
  echo "Install XCode from the App Store..."
  exit 1
else
  echo "XCode is installed"
fi

# Install oh-my-zsh early, since it dominates the ~/.zshrc
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Setting oh-my-zsh to 'spaceship' theme"
# TODO: replace ZSH_THEME var with 'spaceship'

declare xcode_select_installed=`xcode-select --install 2>&1 | grep "command line tools are already installed"`
if [ -z "$xcode_select_installed" ]; then
  echo "Installing xcode-select..."
  xcode-select --install
else
  echo "xcode-select installed"
fi

# TODO: investigate if xcode code dev tools already install homebrew, if so skip below (or add path that supports apple silicon i.e. opt/homebrew)
if [ ! -x /usr/local/bin/brew ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is installed"
fi

# Install all casks specified in `cask.txt`
echo "Installing all brew casks"
brew install --cask $(curl https://raw.githubusercontent.com/ismailshak/dotfiles/main/macos/casks.txt)

echo "Installing 'asdf'"
brew install asdf
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

echo "Installing the nodejs plugin dependencies"
brew install gpg gawk

echo "Installing the nodejs plugin"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

asdf install nodejs latest
asdf global nodejs latest

echo "node --version: $(node --version)"
echo "npm --version: $(npm --version)"

# Install docker
echo "Installing Docker"
brew install docker

echo "Generating an RSA token for GitHub"
mkdir -p ~/.ssh
touch ~/.ssh/config
ssh-keygen -t rsa -b 4096 -C "ismailshak94@yahoo.com"
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
eval "$(ssh-agent -s)"
pbcopy < ~/.ssh/id_rsa.pub
echo "SSH key added to clipboard. Paste that into GitHub"

# TODO: add user prompt to continue here

# if [ ! -x /usr/local/bin/ansible ]; then
#     echo "Installing ansible via Homebrew..."
#     brew install ansible
# else
#     echo "ansible is installed"
# fi

# ansible-playbook -i playbooks/inventory playbooks/main.yml

# docker-compose up -d

# TODO: Install `Input Mono Regular etc` here
# use docker command in the Gist I created

# Install Github CLI
echo "Installing gh"
brew install gh

# Authenticate with gh
gh auth login

# TODO: add a confirmation before this step, or else skip (maybe list repos in a checkbox menu if < 30[or user input, or paginate if im boss] for example)

# Clone all repos for user that just auth'd above
gh repo list --json name | jq '.[].name' | xargs -n1 gh repo clone

# TODO: copy config files around from cloned dotfiles, to correct location


# Install tmux
echo "Installing tmux"
brew install tmux

# Install neovim
echo "Installing neovim"
brew install neovim

# Install NvChad for a quick-n-dirty ready to use neovim setup
git clone https://github.com/NvChad/NvChad ~/.config/nvim

# TODO: copy custom config from github/dotfiles into custom dir in NvChad config
# TODO: install lsp dependencies via npm https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md


# Script complete

# TODO: log the following things I have to run separately
# 1) nvim +'hi NormalFloat guibg=#1e222a' +PackerSync (for nvchad init)

echo "Ready to go!"
