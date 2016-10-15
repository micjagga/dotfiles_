#!/usr/bin/env bash

echo -en "Preparing world domination...\n"

# Include Adam Eivy's library helpers.
source ./lib.sh

# Prevent sleep while install is running
caffeinate &

#####
# Introduction
#####


if [[ "$1" == "-h" || "$1" == "--help" ]]; then cat <<HELP
Usage: $(basename "$0")
See the README for documentation.
https://github.com/micjagga/dotfiles
Copyright (c) 2016 "Temper" Enoc Leonrd
Licensed under the ISC license.
http://leonrdenoc.me/ for more information
HELP
exit; fi
awesome_header

fullname=$(osascript -e "long user name of (system info)")

bot "Hi $fullname. I'm going to make your OSX system better. We're going to:"
action "install Xcode's command line tools"
action "install Homebrew and brew cask"
action "install all the apps that are used at Springload"
action "if you feel like it, we will also install more things"

bot "One more thing: I'll need your password from time to time."

read -r -p "Let's go? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    ok
else
    exit -1;
fi

#####
# install Xcode command line tools
#####

running "checking Xcode CLI install"
xcode_select="xcode-select --print-path"
xcode_install=$($xcode_select) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
    bot "You are missing the Xcode CLI tools. I'll launch the install for you, but then you'll have to restart the process again."
    running "After that you'll need to paste the command and press Enter again."

    read -r -p "Let's go? [y|N] " response
    if [[ $response =~ ^(y|yes|Y) ]];then
        xcode-select --install
    fi

    exit -1
fi
ok

bot "OK, let's roll..."

#####
# install homebrew
#####

running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
    action "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
        error "unable to install homebrew, script $0 abort!"
        exit -1
    fi
fi
ok

running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
    action "installing brew-cask"
    require_brew caskroom/cask/brew-cask
fi
ok

# Make sure we’re using the latest Homebrew
running "updating homebrew"
brew update
brew tap homebrew/versions
brew tap caskroom/versions
ok

./apps.sh

bot "Woot! All done. If you want to go further, here are some options:"

read -r -p "install extra development command-line tools? (node, curl, etc) [y|N] " cli_response
if [[ $cli_response =~ ^(y|yes|Y) ]];then
    ok "will install command-line tools."
else
    ok "will skip command-line tools.";
fi

read -r -p "create our development folder structure (~/Development/sites)? [y|N] " dev_folder_response
if [[ $dev_folder_response =~ ^(y|yes|Y) ]];then
    ok "will create the folder structure."
else
    ok "will skip folder structure.";
fi

if [[ $cli_response =~ ^(y|yes|Y) ]];then
    ./cli.sh
else
    ok "skipped command-line tools.";
fi

if [[ $cli_response =~ ^(y|yes|Y) ]];then
    mkdir -p ~/Development/sites/

    ok "Created ~/Development/sites/"
else
    ok "skipped development folder structure.";
fi

bot "That's it for the automated process. If you want to do more, have a look at the Going Further section:"
running "https://github.com/springload/dotfiles#going-further"

bot "Here are the most useful resources. Have fun!"
running "OSX preferences for hackers: https://github.com/springload/dotfiles#osx-preferences"
running "Mac apps configuration with Mackup: https://github.com/springload/dotfiles#apps-configuration"
running "Dotfiles: https://github.com/springload/dotfiles#dotfiles"
