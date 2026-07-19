#!/usr/bin/env bash
#
# .debian/modules/packages.sh - install packages and tools, wires up dotfiles and uploads SSH keys to GitHub.

APT_MANIFEST="packages/apt.txt"
GH_MANIFEST="packages/github.tsv"

is_apt() { dpkg -s "$1" &>/dev/null; }

# One binary from a GitHub release: latest tag → matching asset → /usr/local/bin.
install_from_github() {
  local repo=$1 asset=$2 binary=$3 url tmp
  url=$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" |
    grep browser_download_url | grep "$asset" | cut -d'"' -f4 | head -n1)

  echo "Installing $binary from $repo ($url)"

  tmp=$(mktempd) # auto-cleaned by lib.sh's trap
  curl -fsSL "$url" -o "$tmp/dl"
  tar -xzf "$tmp/dl" -C "$tmp" 2>/dev/null || cp "$tmp/dl" "$tmp/$binary" # tarball or bare binary

  # find the binary in the extracted files
  local bin_path
  bin_path=$(find "$tmp" -name "$binary" -type f | head -1)
  install_system_file "$bin_path" "/usr/local/bin/$binary" 0755

}

install_docker() {
  # Add Docker's official GPG key:
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to apt sources:
  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_gh() {
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y && sudo apt-get install -y gh
}

GH_SSH_KEY_PATH="$USER_HOME/.ssh/id_ed25519_github"
setup_gh_ssh() {
  # Generate a new SSH key for GitHub if it doesn't exist
  ssh-keygen -t ed25519 -f "$GH_SSH_KEY_PATH" -N "" -C "github@$(hostname)"

  # Register the key for GitHub in SSH config
  local ssh_config="$USER_HOME/.ssh/config"
  mkdir -p "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
  if ! grep -q "Host github.com" "$ssh_config" 2>/dev/null; then
    tee -a "$ssh_config" >/dev/null <<EOF

Host github.com
  IdentityFile $GH_SSH_KEY_PATH
  AddKeysToAgent yes
EOF
    chmod 600 "$ssh_config"
  fi

  # Add the public key to GitHub via the CLI
  gh ssh-key add "$GH_SSH_KEY_PATH.pub" --title "Atlas"
}

install_mise() {
  local install_script
  install_script="/tmp/install.sh"

  # Download and verify the mise install script signature
  gpg --keyserver hkps://keys.openpgp.org --recv-keys 24853EC9F655CE80B48E6C3A8B81C9D17413A06D
  curl https://mise.jdx.dev/install.sh.sig | gpg --decrypt >"$install_script"

  # sudo is needed because the install script `mv`s the binary to /usr/local/bin
  sudo MISE_INSTALL_PATH="/usr/local/bin/mise" sh "$install_script"
}

clone_dotfiles() {
  env GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" gh repo clone "$DOTFILES_REPO" "$CODE_DIR/dotfiles"
}

install_wezterm_terminfo() {
  local tmp tempfile
  tmp=$(mktempd)
  tempfile="$tmp/terminfo"
  curl -o "$tempfile" https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo &&
    chmod a+r "$tempfile" &&
    sudo tic -x -o /etc/terminfo "$tempfile"
}

run_packages() {
  phase "Packages & Tools"
  step "apt update" false -- sudo apt-get update -y

  _raw_arch=$(uname -m)
  case "$_raw_arch" in
  x86_64) ARCH_GNU="x86_64" ARCH_GO="amd64" ARCH_MUSL="x86_64" ARCH_DEB="amd64" ARCH_MIXED="x86_64" ;;
  aarch64) ARCH_GNU="aarch64" ARCH_GO="arm64" ARCH_MUSL="aarch64" ARCH_DEB="arm64" ARCH_MIXED="arm64" ;;
  *)
    echo "Unsupported architecture: $_raw_arch"
    exit 1
    ;;
  esac

  # apt manifest: one package per line, comments start with #
  while read -r pkg; do

    step "apt: $pkg" is_apt "$pkg" -- sudo apt-get install -y "$pkg"
  done < <(grep -vE '^\s*(#|$)' "$APT_MANIFEST")

  # github manifest: name <TAB> repo <TAB> asset <TAB> binary
  while read -r name repo asset binary; do
    # substitute arch placeholders in the asset pattern
    asset="${asset//\{arch.gnu\}/$ARCH_GNU}"
    asset="${asset//\{arch.go\}/$ARCH_GO}"
    asset="${asset//\{arch.musl\}/$ARCH_MUSL}"
    asset="${asset//\{arch.deb\}/$ARCH_DEB}"
    asset="${asset//\{arch.mixed\}/$ARCH_MIXED}"
    step "github: $name" command -v "$binary" -- install_from_github "$repo" "$asset" "$binary"
  done < <(grep -vE '^\s*(#|$)' "$GH_MANIFEST")

  step "mise" command -v mise -- install_mise
  step "docker" command -v docker -- install_docker
  step "gh cli" command -v gh -- install_gh
  note "check $LOG_FILE for the gh auth one-time code"
  step "gh auth" gh auth status -- gh auth login --skip-ssh-key --git-protocol ssh --web --scopes "admin:public_key"
  step "gh ssh" test -f "$GH_SSH_KEY_PATH" -- setup_gh_ssh
  step "dotfiles" test -d "$CODE_DIR/dotfiles" -- clone_dotfiles
  step "dotfiles sync" false -- make -C "$CODE_DIR/dotfiles" sync_dots
  step "wezterm terminfo" infocmp -x wezterm -- install_wezterm_terminfo
}
