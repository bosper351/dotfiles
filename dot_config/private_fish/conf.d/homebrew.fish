abbr --add badd --command 'brew' --set-cursor 'bundle add % && brew bundle'
abbr --add bremove --command 'brew' --set-cursor 'bundle remove % && brew bundle cleanup --zap'

function update -d "Upgrade homebrew packages"
    brew bundle && brew bundle --cleanup
end
