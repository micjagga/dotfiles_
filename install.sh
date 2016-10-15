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
exit;
fi

awesome_header

fullname=$(osascript -e "long user name of (system info)")

bot "Hi $fullname. I'm going to make your OSX system better. We're going to:"
action "install Xcode's command line tools"
action "install Homebrew and brew cask"
action "install all better default applications"
action "if you feel like it, we will also install more things"

bot " I'm going to install some tooling and tweak your system settings. Here I go..."


bot "One more thing: I'll need your password from time to time."

read -r -p "Let's go? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    ok
else
    exit -1;
fi

# Ask for the administrator password upfront
if sudo grep -q "# %wheel\tALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then

# Ask for the administrator password upfront
bot "I need you to enter your sudo password so I can install some things:"
sudo -v

# Keep-alive: update existing sudo time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

bot "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

read -r -p "Make sudo passwordless? [y|N] " response

if [[ $response =~ (yes|y|Y) ]];then
   sed --version 2>&1 > /dev/null
   sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      if [[ $? == 0 ]];then
         sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
     fi
    sudo dscl . append /Groups/wheel GroupMembership $(whoami)
    bot "You can now run sudo commands without password!"
   fi
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

# Wait until the XCode Command Line Tools are installed
until xcode-select --print-path &> /dev/null; do
    sleep 5
done

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

bot "before installing brew packages, we can upgrade any outdated packages."
read -r -p "run brew upgrade? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    # Upgrade any already-installed formulae
    action "upgrade brew packages..."
    brew upgrade --all
    ok "brews updated..."
else
    ok "skipped brew package upgrades.";
fi
fi

# Disable Analytics sent to google
brew analytics off
# Ensure brew works well
brew doctor

# Initial Github configuration
grep 'user = GITHUBUSER' ./git/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    read -r -p "What is your github.com username? " githubuser

  fullname=`osascript -e "long user name of (system info)"`

  if [[ -n "$fullname" ]];then
    lastname=$(echo $fullname | awk '{print $2}');
    firstname=$(echo $fullname | awk '{print $1}');
  fi

  if [[ -z $lastname ]]; then
    lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
  fi
  if [[ -z $firstname ]]; then
    firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
  fi
  email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

  if [[ ! "$firstname" ]];then
    response='n'
  else
    echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
    read -r -p "Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "What is your first name? " firstname
    read -r -p "What is your last name? " lastname
  fi
  fullname="$firstname $lastname"

  bot "Great $fullname, "

  if [[ ! $email ]];then
    response='n'
  else
    echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
    read -r -p "Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "What is your email? " email
    if [[ ! $email ]];then
      error "you must provide an email to configure .gitconfig"
      exit 1
    fi
  fi

  running "replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

  # test if gnu-sed or osx sed
  sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./.home/.gitconfig > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    echo
    running "looks like you are using OSX sed rather than gnu-sed, accommodating"
    sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./git/.gitconfig;
    sed -i '' 's/GITHUBEMAIL/'$email'/' ./git/.gitconfig;
    sed -i '' 's/GITHUBUSER/'$githubuser'/' ./git/.gitconfig;
  else
    echo
    bot "looks like you are already using gnu-sed. woot!"
    sed -i 's/GITHUBEMAIL/'$email'/' ./git/.gitconfig;
    sed -i 's/GITHUBUSER/'$githubuser'/' ./git/.gitconfig;
  fi
fi

# install osx settings, app preferences
read -r -p "would you like to install [macos] applications, apps preferences and better app defaults? [y|N] " appresponse
if [[ $appresponse =~ ^(y|yes|Y) ]];then
    ok "will install [macos] applications, apps preferences and better app defaults "
else
    ok "will skip install of [macos] applications, apps preferences and better app defaults";
fi

read -r -p "would you like to fixed width and powerline-fonts? [y|N] " fontresponse
if [[ $fontresponse =~ ^(y|yes|Y) ]];then
    ok "will install fixed width and powerline-fonts "
else
    ok "will skip install of fixed width and powerline-fonts";
fi


if [[ $appresponse =~ ^(y|yes|Y) ]];then
bash ./apps.sh
else
    ok "skipped Installing [macos] applications, apps preferences and better app defaults.";
fi

if [[ $fontresponse =~ ^(y|yes|Y) ]];then
bash ./fonts/install.sh
ok
else
    ok "skipped Installing fixed width and powerline-fonts.";
fi


bot "Woot! All done. If you want to go further, here are some options:"

# Warn user this script will overwrite current dotfiles

while true; do
  read -p "Warning: this will overwrite your current dotfiles. Continue? [y/n] " yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) bot "Please answer yes or no.";;
  esac
done

read -r -p "install extra development command-line tools? (node, curl, etc) [y|N] " cli_response
if [[ $cli_response =~ ^(y|yes|Y) ]];then
    ok "will install command-line tools."
else
    ok "will skip command-line tools.";
fi

read -r -p "create our development folder structure (~/Developer/sites)? [y|N] " dev_folder_response
if [[ $dev_folder_response =~ ^(y|yes|Y) ]];then
    ok "will create the folder structure."
else
    ok "will skip folder structure.";
fi

if [[ $cli_response =~ ^(y|yes|Y) ]];then
    bash ./cli.sh
else
    ok "skipped command-line tools.";
fi

if [[ $cli_response =~ ^(y|yes|Y) ]];then
    mkdir -p ~/Developer/sites/

    ok "created ~/Developer/sites/"
else
    ok "skipped development folder structure.";
fi



action "setting up your macos® ..."; ok
running "initialisaing home..."

running "~/Documents/Temp"
mkdir -p ~/Documents/Temp
running "~/Documents/Temp/Scratch"
mkdir -p ~/Documents/Temp/Scratch
running "~/Documents/Projects"
mkdir -p ~/Documents/Projects
ok


bot "I'm going to set up node® for your system... "

read -r -p "Would you like me to do this? [y|N] " noderesponse
if [[ $noderesponse =~ ^(y|yes|Y) ]];then
    ok "will set up node® "
else
    ok "will skip node® setup.";
fi

if [[ $noderesponse =~ ^(y|yes|Y) ]];then

bot "Installing a stable version of Node..."
sourceNVM
# Install the latest stable version of node
nvm install stable
# Switch to the installed version
# nvm use node
# Use the stable version of node by default
 nvm alias default node
else
    ok "Skipped setting up node®";
fi

bot "I'm going to set up python® for your system...python® 3 is set as default you can change this with pyenv.. "

read -r -p "Would you like me to do this? [y|N] " pyresponse
if [[ $pyresponse =~ ^(y|yes|Y) ]];then
    ok "will set up python® "
else
    ok "will skip setting up python®";
fi


if [[ $pyresponse =~ ^(y|yes|Y) ]];then
    bot "Installing a stable version of python..."
    bot "Installing the dev version of python 3 & miniconda..."
    pyenv install 3.5.2
    pyenv install miniconda-latest
    ok
action "Setting python 3 -miniconda globally"
    pyenv global miniconda-latest

action 'updating pip'
    easy_install pip


else
    ok "Skipping python® setup.";
fi

bot "I'm going to set up Rubies® for your system... "

read -r -p "Would you like me to do this? [y|N] " rubyresponse
if [[ $rubyresponse =~ ^(y|yes|Y) ]];then
    ok "will set up ruby® "
else
    ok "will skip ruby® setup.";
fi

if [[ $rubyresponse =~ ^(y|yes|Y) ]];then

bot "Installing a stable version of Ruby..."
action "Making ~/.rubies folder if it doesn't exist"
mkdir ~/.rubies
ok
action "Getting list of latest version of ruby"
bot "Installing latests versions od ruby"
ruby-install --latest ruby
ok
bot "Setting default ruby to 2.3.1"
echo "chruby 2.3.1" >> ~/.ruby-version
ok

read -r -p "Would you like me to install pow? [y|N] " powresponse
if [[ $powresponse =~ ^(y|yes|Y) ]];then
    ok "will set up pow® "
else
    ok "will skip pow setup.";
fi
if [[ $powresponse =~ ^(y|yes|Y) ]];then
curl get.pow.cx | sh
ok

bot "To set up a Rails or Rack app just symlink it to ~/.pow"
action "=================================="
bot "cd ~/.pow"
bot "ln -s /path/to/myapp"
action "=================================="
fi

ruby -v
read -r -p "Would you like me to install Rails? [y|N] " railresponse
if [[ $railresponse =~ ^(y|yes|Y) ]];then
    ok "will set install and setup rails® "
else
    ok "will skip installing rails.";
fi
if [[ $railresponse =~ ^(y|yes|Y) ]];then
    require_gem rails
    require_gem mysql
    ok "Rails has been installed"
else
    ok "Skipped rails installation®";
fi
else
    ok "Skipped setting up ruby®";
fi


running "cleanup homebrew"
brew cleanup > /dev/null 2>&1
ok

bot "I'm going to install some resonable [macos] defaults (General system UI, Standard System Changes.., etc). "

read -r -p "Would you like me to do this? [y|N] " osresponse
if [[ $osresponse =~ ^(y|yes|Y) ]];then
    ok "will install some resonable [macos] defaults."
else
    ok "will skip installing some resonable [macos] defaults.";
fi

if [[ $osresponse =~ ^(y|yes|Y) ]];then
bash ./macos/osx-defaults.sh
else
    ok "Skipped installing some resonable [macos] defaults.";
fi

sh -c "`curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh`" -s ask
###############################################################################
# Kill affected applications                                                  #
###############################################################################
bot "OK. Note that some of these changes require a logout/restart to take effect. Killing affected applications (so they can reboot)...."
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SizeUp" "SystemUIServer" \
  "iCal" "iterm 2"; do
  killall "${app}" > /dev/null 2>&1
done
ok

# bot "I will now back up your configurations and setting to Dropbox (\n make sure you're logged in)"
# action "Backing Up "
# mackup backup
# ok

bot "Woot! All done."

# Wait a bit before moving on...
sleep 1

# ...and then.
bot "Success! Defaults are set."
bot "Some changes will not take effect until you reboot your machine."

# See if the user wants to reboot.
function reboot() {
 read -p "Do you want to reboot your computer now? (y/N)" choice
 case "$choice" in
   y | Yes | yes ) echo "Yes"; exit;; # If y | yes, reboot
   n | N | No | no) echo "No"; exit;; # If n | no, exit
   * ) warn "Invalid answer. Enter \"y/yes\" or \"N/no\"" && return;;
 esac
}

# Call on the function
if [[ "Yes" == $(reboot) ]]
then
 action "Rebooting."
 sudo reboot
 exit 0
else
 exit 1
fi



##################################################################################

bot "That's it for the automated process. If you want to do more, have a look at Github unofficial dotfiles:"
running "https://dotfiles.github.io"

bot "Here are the most useful resources. Have fun!"
running "OSX preferences for hackers: https://github.com/springload/dotfiles#osx-preferences"
running "Mac apps configuration with Mackup: https://github.com/springload/dotfiles#apps-configuration"
running "Dotfiles: https://github.com/micjagga/dotfiles_"
