# Commands to run in interactive sessions can go here
abbr -a vim nvim
abbr -a g git
abbr -a ec emacsclient

# Make !! work as in bash/zsh
function __last_history_item
    echo $history[1]
end
abbr -a !! --position anywhere --function __last_history_item
