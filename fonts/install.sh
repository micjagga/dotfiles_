#!/usr/bin/env bash
# =======================================================================================
# This Script installs fixed width  and powerline fonts(Patched) for developments
# You can select the ones you need and take out the rest.
# ========================================================================================

# some colorized echo helpers
# Thanks to Adam Eivy https://github.com/atomantic/dotfiles
source ./lib.sh


bot "Installing fonts..."
brew tap caskroom/fonts

running "Installing some fonts from Brew Cask.."
require_cask font-sauce-code-powerline
require_cask font-fontawesome
require_cask font-open-sans
require_cask font-pt-sans
require_cask font-source-sans-pro
ok

action "Setting source and target directories"
powerline_fonts_dir=$( cd "$( dirname "$0" )" && pwd )
action "Locating indexed/patched fonts..."
find_command="find \"$powerline_fonts_dir\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"; ok

if [[ `uname` == 'Darwin' ]]; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p $font_dir
fi

# Copy all fonts to user fonts directory
action "Copying fonts to system..."
eval $find_command | xargs -0 -I % cp "%" "$font_dir/"; ok

# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    action "Resetting font cache, this may take a moment..."
    fc-cache -f $font_dir
fi
ok
bot "All Powerline fonts installed to $font_dir"
bot "Woot! All done."
