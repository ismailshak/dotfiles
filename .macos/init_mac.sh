#!/usr/bin/env bash

# ~/.macos — https://github.com/kentcdodds/dotfiles/blob/master/.macos
# Modified by Ismail Elshakankiry
# Run without downloading:
# curl https://raw.githubusercontent.com/ismailshak/dotfiles/main/macos/.macos | bash

#
# TODO:
#     - prettify logs
#     - add log proxies to commands so that I can add tags/headers/prefixes to them in stdout (to identify progress by prefix)
#     - add prompts for user interactions (--interactive mode basically)
#     - add a way to supply env variables to override things (i.e. make this more dynamic)
#     - fully support both architecures for every command (x86 vs arm64)
#     - redirect useless command logging into files and replace with spinners
#     - make logs more verbose when communicating progress e.g. check mark steps and spinners
#     - create functions that encapsulate functionality e.g. handling redirects if file doesn't exist etc
#

CODE_DIR="code"

# Ask for the administrator password upfront
echo "Admin login required for script permissions"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Hello $(whoami)! Let's get you set up."

echo "Creating code directory; '${HOME}/${CODE_DIR}'"
mkdir -p "${HOME}/${CODE_DIR}"

if [[ `xcode-select -p` != "/Applications/Xcode.app/Contents/Developer" && `xcode-select -p` != "/Applications/Xcode-beta.app/Contents/Developer" ]]; then
  echo "Install Xcode from the App Store..."
  # TODO: instead of exiting maybe we can wait for a confirmation and loop check until it is
  exit 1
else
  echo "Xcode is installed"
fi

# Install oh-my-zsh early, since it dominates the ~/.zshrc
echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# TODO: replace ZSH_THEME var with 'spaceship'
# echo "Setting oh-my-zsh to 'spaceship' theme"

declare xcode_select_installed=`xcode-select --install 2>&1 | grep "command line tools are already installed"`
if [ -z "$xcode_select_installed" ]; then
  echo "Installing xcode-select..."
  xcode-select --install
else
  echo "xcode-select installed"
fi

# TODO: check if git and homebrew were installed by xcode-select and add installs/skips where needed

# TODO: add path that supports apple silicon i.e. opt/homebrew
if [ ! -x /usr/local/bin/brew ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is installed"
fi

echo "Generating an RSA token for GitHub"
mkdir -p ~/.ssh
touch ~/.ssh/config
ssh-keygen -t rsa -b 4096 -C "ismailshak94@yahoo.com"
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
eval "$(ssh-agent -s)"
pbcopy < ~/.ssh/id_rsa.pub
echo "SSH key copied to clipboard. Paste that into an SSH key entry here: https://github.com/settings/keys"

# TODO: loop; check ssh key status and paste key to clipboard again and wait for confirmation

# Install Github CLI
echo "Installing gh"
brew install gh

# Authenticate with gh
gh auth login

# TODO: add a confirmation before this next step so it can be skipped
# (maybe list repos in a checkbox menu if < 30[or user input, or paginate if im boss] for example)

# Clone all repos for user that just auth'd above
cd ~/$CODE_DIR
gh repo list --json name --jq '.[].name' | xargs -n1 gh repo clone
cd ~

echo "Appending remote .zshrc into local ~/.zshrc"
cat ~/$CODE_DIR/dotfiles/.zshrc >> ~/.zshrc

echo "Appending remote .gitconfig into local ~/.gitconfig"
cat ~/$CODE_DIR/dotfiles/.gitconfig >> ~/.gitconfig

echo "Installing 'asdf'"
brew install asdf
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc

echo "Installing the nodejs plugin dependencies"
brew install gpg gawk

echo "Installing the nodejs plugin"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# TODO: add a prompt to ask for specific node version, default to latest

asdf install nodejs latest
asdf global nodejs latest

echo "node --version: $(node --version)"
echo "npm --version: $(npm --version)"

# Install docker
echo "Installing Docker"
brew install docker

# Install all casks specified in `cask.txt`
echo "Installing all brew casks"
brew install --cask $(curl https://raw.githubusercontent.com/ismailshak/dotfiles/main/.macos/casks.txt)

# TODO: Install `Input Mono Regular etc` here
# use docker command in the Gist I created

# Install tmux
echo "Installing tmux"
brew install tmux

echo "Appending remote .tmux.conf into local ~/.tmux.conf"
cat ~/$CODE_DIR/dotfiles/.tmux.conf >> ~/.tmux.conf

# Install neovim
echo "Installing neovim"
brew install neovim

# Install NvChad for a quick-n-dirty ready to use neovim setup
git clone https://github.com/NvChad/NvChad ~/.config/nvim

echo "Copying remote NvChad custom config into local ~/.config/nvim/lua/custom/*"
cp -r "~/$CODE_DIR/dotfiles/"* "~/.config/nvim/lua/custom"

# TODO: install lsp dependencies via npm https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md

# Script complete

# TODO: log the following things I have to run separately
# 1) nvim +'hi NormalFloat guibg=#1e222a' +PackerSync (for nvchad init)

echo "Ready to go!"
