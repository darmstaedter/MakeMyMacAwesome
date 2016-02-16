#!/bin/sh

## XCode Commandline Tools
xcode-select --install

## Install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## Install ruby 2.3.0
brew install rbenv ruby-build

echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

rbenv install 2.3.0
rbenv global 2.3.0

## Install rails 4.2.5.1
gem install rails -v 4.2.5.1
rbenv rehash

## Install Homebrew Cask
brew install caskroom/cask/brew-cask

## Install Software
brew install git
brew install nodejs
brew install youtube-dl
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
brew cask install coda
brew cask install keka
brew cask install adobe-creative-cloud
brew cask install sqlitebrowser

## Install Atom
brew cask install atom
apm install `curl -fsSL https://raw.githubusercontent.com/Darmstaedter/MakeMyMacAwesome/master/atom_packages.list`

## Install Private Scripts
brew tap sewolt/sewolt git@bitbucket.org:darmstaedter/sewolt-homebrew.git
brew install sewolt
