#!/bin/bash

set -e

# brew
if ! command -v brew 1>/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew install rbenv ruby-build graphicsmagick svn

# rbenv
export PATH="$HOME/.rbenv/shims:$PATH"
ruby_version=`cat .ruby-version`
if [[ ! -d "$HOME/.rbenv/versions/$ruby_version" ]]; then
    rbenv install $ruby_version
    rbenv rehash
fi

# App
git submodule update --init --recursive
gem install bundler
bundle install

# Hint
echo -e "\n\n\n"
echo -e "\033[33m====== setup warning ======\033[0m"
echo -e "\033[33mPlease run 'benv init' in your terminal and follow the printed instructions.\033[0m"
