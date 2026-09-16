#!/usr/bin/env bash

configure_general() {
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -int 0
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -int 0
  # tap to click
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # 2 is the fastest the UI allows
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
}

configure_finder() {
  defaults write com.apple.finder FXRemoveOldTrashItems -bool true
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  killall Finder
}

configure_dock() {
  defaults write com.apple.dock autohide -int 1
  defaults write com.apple.dock tilesize -int 46
  killall Dock
}

run_settings() {
  phase "macOS Settings"
  step "general" false -- configure_general
  step "finder" false -- configure_finder
  step "dock" false -- configure_dock
}
