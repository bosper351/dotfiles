function pygrep --wraps ggrep -d "grep Python files"
    ggrep --color=auto -nr --include='*.py' $argv
end
