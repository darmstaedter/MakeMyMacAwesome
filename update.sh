#!/bin/sh

brew update
brew upgrade

## Install ruby 2.3.0
rbenv uninstall 2.2.3 -f
rbenv install 2.3.0
rbenv global 2.3.0

# RubyGems Update
gem update --system

## Install rails 4.2.5.1
gem install rails -v 4.2.5.1
rbenv rehash

gem update
gem pristine --all
