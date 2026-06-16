# GNU tools from homebrew
set -l gnu_brews findutils gawk gnu-sed
fish_add_path --global /opt/homebrew/opt/$gnu_brews/libexec/gnubin
fish_add_path --global /opt/homebrew/opt/curl/bin

# grep needs a special treatment to pick up color flag
function grep --wraps ggrep
    command ggrep --color="auto" $argv
end

# Mac chmod does not support --reference
abbr --add 'reference' --command 'chmod' --set-cursor=%% "(stat -f '%p' %% | string sub --start 2)"
