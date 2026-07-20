#!/bin/zsh

set -eufo pipefail

brew bundle --file=<(cat ~/.config/homebrew/*.brewfile)
