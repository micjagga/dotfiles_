#!/usr/bin/env bash

###
# some bash library helpers
# @author Adam Eivy https://github.com/atomantic/dotfiles
###

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"

function ok() {
    echo -e "$COL_GREEN[ok]$COL_RESET $1"
}

function bot() {
    echo -e "\n$COL_GREEN(っ◕‿◕)っ$COL_RESET - $1"
}

function running() {
    echo -en "$COL_YELLOW ⇒ $COL_RESET $1: "
}

function action() {
    echo -e "\n$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

function warn() {
    echo -e "$COL_YELLOW[warning]$COL_RESET $1"
}

function error() {
    echo -e "$COL_RED[error]$COL_RESET $1"
}

function awesome_header() {
    echo -en "\n$COL_GREEN          ██            ██     ████ ██  ██ $COL_RESET"
    echo -en "\n$COL_GREEN         ░██           ░██    ░██░ ░░  ░██ $COL_RESET"
    echo -en "\n$COL_GREEN         ░██  ██████  ██████ ██████ ██ ░██  █████   ██████ $COL_RESET"
    echo -en "\n$COL_GREEN      ██████ ██░░░░██░░░██░ ░░░██░ ░██ ░██ ██░░░██ ██░░░░ $COL_RESET"
    echo -en "\n$COL_GREEN     ██░░░██░██   ░██  ░██    ░██  ░██ ░██░███████░░█████ $COL_RESET"
    echo -en "\n$COL_GREEN    ░██  ░██░██   ░██  ░██    ░██  ░██ ░██░██░░░░  ░░░░░██ $COL_RESET"
    echo -en "\n$COL_GREEN    ░░██████░░██████   ░░██   ░██  ░██ ███░░██████ ██████ $COL_RESET"
    echo -en "\n$COL_GREEN     ░░░░░░  ░░░░░░     ░░    ░░   ░░ ░░░  ░░░░░░ ░░░░░░ $COL_RESET"
    echo -en "\n$COL_GREEN  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓$COL_RESET"
    echo -en "\n$COL_GREEN  ░▓ Software Installation, Configuration and Preferences for OS ▓$COL_RESET"
    echo -en "\n$COL_GREEN  ░▓ https://github.com/micjagga/dotfiles                        ▓$COL_RESET"
    echo -en "\n$COL_GREEN  ░▓ Enoc Leonrd - http://leonrdenoc.me                          ▓$COL_RESET"
    echo -en "\n$COL_GREEN  ░▓ For more help add -h or --help to install script            ▓$COL_RESET"
    echo -en "\n$COL_GREEN  ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓$COL_RESET"
    echo -en "\n"
}

function require_cask() {
    running "brew cask $1"
    brew cask list "$1" > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        action "brew cask install $1 $2"
        brew cask install "$1"
        if [[ $? != 0 ]]; then
            error "failed to install $1!"
        fi
    fi
    ok
}

function require_brew() {
    running "brew $1 $2"
    brew list "$1" > /dev/null 2>&1 | true
    if [[ ${PIPESTATUS[0]} != 0 ]]; then
        action "brew install $1 $2"
        brew install "$1" "$2"
        if [[ $? != 0 ]]; then
            error "failed to install $1!"
        fi
    fi
    ok
}

function require_node(){
    running "node -v"
    node -v
    if [[ $? != 0 ]]; then
        action "node not found, installing via homebrew"
        brew install node
    fi
    ok
}

function require_npm() {
    sourceNVM
    running "npm $*"
    npm list -g --depth 0 | grep $1@ > /dev/null
    if [[ $? != 0 ]]; then
        action "npm install -g $*"
        npm install -g $@
    fi
    ok
}

function require_apm() {
    running "checking atom plugin: $1"
    apm list --installed --bare | grep $1@ > /dev/null
    if [[ $? != 0 ]]; then
        action "apm install $1"
        apm install $1
    fi
    ok
}

function sourceNVM(){
    export NVM_DIR=~/.nvm
    source $(brew --prefix nvm)/nvm.sh
}


function require_gem() {
        running "gem $1"
        if [[ $(gem list --local | grep "$1" | head -1 | cut -d' ' -f1) != "$1" ]];
            then
              action "gem install $1"
              gem install "$1"
        fi
        ok
    }

function require_pip() {
    running "pip $1"
    if [[ $(pip list --local | grep "$1" | head -1 | cut -d' ' -f1) != "$1" ]];
        then
          action "pip install $1"
          pip install "$1"
    fi
    ok
}

npmlist=$(npm list -g)
function require_npm() {
    sourceNVM
    running "npm $1"
    echo "$npmlist" | grep "$1@" > /dev/null
    if [[ $? != 0 ]]; then
        action "npm install -g $1"
        npm install -g "$1"
    fi
    ok
}
