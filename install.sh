#!/bin/sh

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
