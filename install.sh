#!/bin/sh

## XCode Commandline Tools
xcode-select --install

## Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Install ruby 2.2.3
brew install rbenv ruby-build

echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

rbenv install 2.2.3
rbenv global 2.2.3

## Install rails 4.2.4
gem install rails -v 4.2.4
rbenv rehash

## Install Homebrew Cask
brew install caskroom/cask/brew-cask

## Install Software
brew install git
brew install nodejs
brew cask install google-chrome
brew cask install postgres
brew cask install skype
brew cask install slack
brew cask install sketch sketch-tool sketch-toolbox
brew cask install tower
brew cask install transmit
brew cask install sequel-pro
brew cask install iterm2
brew cask install firefox
brew cask install vlc
brew cask install mplayerx
brew cask install coda
brew cask install atom
brew cask install keka
brew cask install adobe-creative-cloud
