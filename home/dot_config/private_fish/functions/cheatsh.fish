function cheatsh -d "Online cheat sheet for cli commands"
    curl -s "https://cheat.sh/$argv[1]" | less -R
end
