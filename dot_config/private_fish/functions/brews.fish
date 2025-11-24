# Stolen from https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/brew/brew.plugin.zsh
function brews -d "List installed brews"
    set -l formulae (brew leaves | xargs brew deps --installed --for-each)
    set -l casks (brew list --cask 2>/dev/null)

    echo (set_color blue)"==>"(set_color normal) (set_color -o)"Formulae"(set_color normal)
    printf "%s\n" $formulae
    echo ""
    echo (set_color blue)"==>"(set_color normal) (set_color -o)"Casks"(set_color normal)
    printf "%s\n" $casks
end
