#!/bin/bash

set -e

title() {
    echo -e "\033[32m$1\033[0m"
}

message() {
    echo -e "  \033[32m->\033[0m $1"
}

error() {
    echo -e "    \033[31mError: $1\033[0m"
    exit 1
}

install_brew() {
    message 'install brew'

    if ! command -v brew 1>/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

install_formulae() {
    message 'install formulae'

    brew install rbenv ruby-build graphicsmagick svn
}

check_brew() {
    title 'Checking brew'

    install_brew
    install_formulae
}

setup_rbenv() {
    message 'setup rbenv'

    case $(basename "$SHELL") in
    "bash")
        config_file="$HOME/.bash_profile"
        ;;
    "zsh")
        config_file="$HOME/.zshrc"
        ;;
    "fish")
        config_file="$HOME/.config/fish/config.fish"
        ;;
    *)
        error "Unsupported shell: $shell_name"
        ;;
    esac
    if ! grep -q 'rbenv init' "$config_file"; then
        echo 'eval "$(rbenv init -)"' >> "$config_file"
    fi
    eval "$(rbenv init -)"
}

install_ruby() {
    local ruby_version=3.1.2
    message "install ruby $ruby_version"

    if ! rbenv versions | grep -q "$ruby_version"; then
        rbenv install "$ruby_version"
    fi
    rbenv global "$ruby_version"
}

install_gems() {
    message 'install gems'

    gem install bundler

    if [ -n "$GEMS_REPO" ]; then
        for repo in $(echo "$GEMS_REPO" | tr ',' '\n'); do
            local repo_name=$(basename "$repo" .git)
            local repo_dir=$(mktemp -d)
            git clone "$repo" "$repo_dir"
            cd "$repo_dir"
            bundle install
            gem build *.gemspec
            gem install *.gem --local
            cd -
            rm -rf "$repo_dir"
        done
    fi
}

check_ruby() {
    title 'Checking ruby'

    setup_rbenv
    install_ruby
    install_gems
}

check_brew
check_ruby
