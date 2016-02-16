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

# Update node
sudo rm -rf /usr/local/lib/node_modules
brew uninstall node
brew install node --without-npm
echo prefix=~/.npm-packages >> ~/.npmrc
curl -L https://www.npmjs.com/install.sh | sh
echo 'export PATH="$HOME/.node/bin:$PATH"' >> ~/.bash_profile



source ~/.bash_profile
