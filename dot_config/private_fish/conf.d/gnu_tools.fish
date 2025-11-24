# GNU tools from homebrew
set -l gnu_brews findutils gawk gnu-sed
fish_add_path --global /opt/homebrew/opt/$gnu_brews/libexec/gnubin

# grep needs a special treatment to pick up color flag
function grep --wraps ggrep
    command ggrep --color="auto" $argv
end
