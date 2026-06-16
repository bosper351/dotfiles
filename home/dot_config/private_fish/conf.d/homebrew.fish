# Homebrew env variables
eval "$(/opt/homebrew/bin/brew shellenv)"

set -gx HOMEBREW_BUNDLE_FILE $XDG_CONFIG_HOME/homebrew/Brewfile
