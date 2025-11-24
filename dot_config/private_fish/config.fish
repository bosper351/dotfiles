if status is-interactive
    # Commands to run in interactive sessions can go here
end

eval "$(/opt/homebrew/bin/brew shellenv)"

set -gx EDITOR /opt/homebrew/bin/nvim
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx HOMEBREW_BUNDLE_FILE $XDG_CONFIG_HOME/homebrew/Brewfile

abbr -a vcr 'code -r'
abbr -a vim nvim
abbr -a g git
abbr -a la --position command ls -Alh

# Make !! work as in bash/zsh
function __last_history_item
    echo $history[1]
end
abbr -a !! --position anywhere --function __last_history_item
