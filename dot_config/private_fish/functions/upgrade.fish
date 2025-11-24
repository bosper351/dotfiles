function upgrade -d "List installed brews"
    brew bundle upgrade
    brew bundle cleanup --force
end
