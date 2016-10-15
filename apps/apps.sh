##!/usr/bin/env bash

# =============================================================================
# This script installs GUI Applications and other useful
# utilities used by developers.
# The script also sets up a few applications.
# Should be customised to fit your requirements
# The script is made up of daily use applications,
# designer applications, developer tools, quicklook plugins
# and other useful utilities like vpn etc.
# =============================================================================


# some colorized echo helpers
# Thanks to Adam Eivy https://github.com/atomantic/dotfiles
source ./lib.sh

bot "Initialise Application Tools™"
bot "Set up buxbot (better defaults)™"

read -r -p "install default tools for everyday use? (Browsers, Slack, etc) [y|N] " d_response
if [[ $d_response =~ ^(y|yes|Y) ]];then
    ok "will install everyday tools."
else
    ok "will skip everyday tools.";
fi

read -r -p "install designer tools? (Dropbox, Sketch, etc) [y|N] " ds_response
if [[ $ds_response =~ ^(y|yes|Y) ]];then
    ok "will install designer tools."
else
    ok "will skip designer tools.";
fi

read -r -p "install developer tools? (iTerm, Sublime Text, etc) [y|N] " dv_response
if [[ $dv_response =~ ^(y|yes|Y) ]];then
    ok "will install developer tools."
else
    ok "will skip developer tools.";
fi

read -r -p "install Quicklook plugins? [y|N] " ql_response
if [[ $qlresponse =~ ^(y|yes|Y) ]];then
    ok "will install Quicklook plugins."
else
    ok "will skip Quicklook plugins.";
fi

read -r -p "install other useful Utility tools? (flux, Cdock, duet, displayLink etc) [y|N] " u_response
if [[ $u_response =~ ^(y|yes|Y) ]];then
    ok "will install Utility tools."
else
    ok "will skip Utility tools.";
fi

bot "Let's go! Make sure to check on your computer regularly in case something needs your password."

if [[ $d_response =~ ^(y|yes|Y) ]];then
    action "install brew cask packages..."
    require_cask firefox
    require_cask google-chrome
    require_cask google-drive
    #require_cask avast
    require_cask alfred
    require_cask skype
    # require_cask google-hangouts
    require_cask slack
    #require_cask harvest
    #require_cask vlc
    require_cask fluid
    require_cask spotify
    require_cask steam
    require_cask transmission
    require_cask typora
    require_cask microsoft-office
    require_cask notion


    ok "Music Players, Messangers, Utility Apps, Browsers etc. All set!"
    ok "Daily casks installed..."
else
    ok "skipped everyday tools.";
fi

if [[ $ds_response =~ ^(y|yes|Y) ]];then

    action "install brew cask packages..."
    require_cask dropbox
    require_cask sketch
    require_cask skyfonts
    # might add icons app at some point
    # require_cask adobe-creative-cloud
    ok "Dropbox, Sketch etc. All set!"
    ok "casks installed..."
else
    ok "skipped designer tools.";
fi

if [[ $dv_response =~ ^(y|yes|Y) ]];then

    action "install brew cask packages..."
    require_cask intellij-idea
    require_cask pycharm
    require_cask atom
    require_cask sublime-text
    require_cask visual-studio-code
    require_cask google-chrome-canary
    require_cask whiskey
    require_cask macdown
    require_cask datagrip
    require_cask dash
    # require_cask opera
    require_cask iterm2
    require_cask vagrant
    require_cask virtualbox
    require_cask ngrok
    require_cask screenhero
    require_cask gitup
    require_cask sourcetree
    require_cask imagealpha
    require_cask imageoptim
    require_cask querious
    require_cask kaleidoscope
    # require_cask pgadmin3

    ok "IDE's, Git clients, Database Management Apps, Text Editors etc. All set!"
    ok  "Developer casks installed..."
else
    ok "skipped developer tools.";
fi

if [[ $ql_response =~ ^(y|yes|Y) ]];then

    action "install brew cask packages..."
    require_cask qlcolorcode
    require_cask qlstephen
    require_cask qlmarkdown
    require_cask quicklook-json
    require_cask qlprettypatch
    require_cask quicklook-csv
    require_cask betterzipql
    require_cask webpquicklook
    require_cask suspicious-package
    require_cask epubquicklook

    ok "casks installed..."
else
    ok "skipped Quicklook plugins";
fi

if [[ $u_response =~ ^(y|yes|Y) ]];then

    action "install brew cask packages..."
    require_cask flux
    require_cask raindrop #hope its the updated version
    require_cask tunnelbear
    require_cask bartender
    require_cask superduper
    require_cask bitbar
    require_cask totalfinder
    require_cask cdock
    require_cask duet
    require_cask displaylink
    require_cask adguard
    require_cask bestres
    require_cask little-snitch
    require_cask revisions

    ok "Addtional System Utilities all set!"
    ok "Utilities Casks installed"
else
    ok "skipped Utility tools.";
fi


# ================================================================================
# Setup applications
# ===============================================================================
bot "Setting Up Applications..."

read -r -p "would you like to install a few Atom community packages? [y|N] " atomresponse
if [[ $atomresponse =~ ^(y|yes|Y) ]];then
    ok "will install atom packages."
else
    ok "will skip installing atom packages.";
fi

read -r -p "would you like to set up sublime text 3 [y|N] " subresponse
if [[ $subresponse =~ ^(y|yes|Y) ]];then
    ok "will setup sublime text 3."
else
    ok "will skip setting up sublime text 3.";
fi

read -r -p "would you like to configure Terminal and Iterm 2 with sane defauts [y|N] " termresponse
if [[ $termresponse =~ ^(y|yes|Y) ]];then
    ok "will configure terminal & iterm."
else
    ok "will skip configuring terminal & iterm.";
fi

if [[ $atomresponse =~ ^(y|yes|Y) ]];then
    bot "Atom"
    action "install atom community packages..."
    action 'Symlinking Atom to [~/]'
    running "Copying Atom settings.."
    mv  -f ~/.atom ~/.dotfiles_backup/
    ln -s ./apps/atom ~/.atom; ok

    running "Copying over Atom packages"
    cp -r ./apps/atom/packages.list ~/.atom; ok
    running "Installing Atom community packages"
    apm list --installed # --bare  - get a list of installed packages
    apm install --packages-file ~/.atom/packages.list; ok
    require_apm linter-flake8
    require_apm linter-pep8
    require_apm autocomplete-python
    require_apm django-templates
else
    ok "skipped Installing Atom Community Packages.";
fi

if [[ $termresponse =~ ^(y|yes|Y) ]];then
bot 'iTerm 2'
source ./apps/iterm2/install.sh
else
    ok "skipped configuring iterm 2 and terminal.";
fi

if [[ $subresponse =~ ^(y|yes|Y) ]];then
bot "Initialising..."
source ./apps/sublimetext3/install.sh
ok
else
    ok "skipped setting up sublime text 3.";
fi

bot "All done!"
bot "Applications are a go!!"
