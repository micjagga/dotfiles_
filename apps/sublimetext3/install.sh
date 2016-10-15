#!/bin/sh
source ./config/echos.sh
# ========================================================================================
# This script handles the sublime text editor.
# Better defaults/preferences are symlinked also,
# package control is installed automatically as well as other indispensible sublime packages
# ===========================================================================================

# =========================================================================================
bot "Setting up Sublime Text 3..."
# ==========================================================================================

running "Ensuring library directory exists..."
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Packages
mkdir -p ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages
ok

action "Symlinking user preferences"
running 'Linking Preferences...'
ln -s ~/.dotfiles/apps/sublime\ text\ 3/preferences ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User;ok
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl;ok

# Install Package Control
bot "Installing package control for sublime text"
curl -o ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/Package\ Control.sublime-package https://packagecontrol.io/Package\ Control.sublime-package
ok
action "Changing Sublime Text 3 Icon.."
mv  -f ~/Applications/Sublime\ Text.app/Contents/Resources/Sublime\ Text.icns ~/.dotfiles_backup;
ln  -s ./apps/sublime\ text\ 3/Sublime\ Text\ Icons/Sublime\ Text.icns ~/Applications/Sublime\ Text.app/Contents/Resources;
ok
bot "All done! Sublime Text 3 is good to go! woot!"


